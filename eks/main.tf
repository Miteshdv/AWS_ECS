terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# IAM Module
module "iam" {
  source = "./modules/iam"
}

# VPC Module
module "vpc" {
  source                    = "./modules/vpc"
  name                      = "ecs-vpc"
  cidr_block                = "10.0.0.0/16"
  public_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones        = ["us-west-2a", "us-west-2b"]
}

# Security Group Module
module "security_group" {
  source              = "./modules/security"
  name                = "ec2-sg"
  description         = "ECS security group"
  vpc_id              = module.vpc.vpc_id
  ingress_from_port   = 8000
  ingress_to_port     = 8000
  ingress_protocol    = "tcp"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_from_port    = 0
  egress_to_port      = 0
  egress_protocol     = "-1"
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

# EKS Module
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = "python-eks-cluster"
  iam_role_name                  = module.iam.eks_cluster_role_name
  subnet_ids                     = module.vpc.public_subnet_ids
  vpc_id                         = module.vpc.vpc_id
  cluster_version                = "1.25"
  enable_irsa                    = true
  cluster_endpoint_public_access = true
}

# EKS Workers Module
module "eks_workers" {
  source               = "./modules/eks_workers"
  cluster_name         = module.eks.cluster_name
  image_id             = "ami-055e3d4f0bbeb5878" # Replace with your desired AMI ID
  instance_type        = "t2.micro"
  key_name             = var.key_name
  security_groups      = [module.security_group.security_group_id]
  subnet_ids           = module.vpc.public_subnet_ids
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  iam_instance_profile = module.iam.eks_worker_profile_name

}

# ALB Module
module "alb" {
  source          = "./modules/alb"
  name            = "eks-alb"
  security_groups = [module.security_group.security_group_id]
  subnets         = module.vpc.public_subnet_ids
  vpc_id          = module.vpc.vpc_id
  tags = {
    Name = "eks-alb"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = module.eks_workers.autoscaling_group_name
  lb_target_group_arn    = module.alb.alb_target_group_arn
}

# Kubernetes Module
module "kubernetes" {
  source                 = "./modules/kubernetes"
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}


resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region us-west-2 update-kubeconfig --name ${module.eks.cluster_name}"
  }

  depends_on = [module.eks]
}

# Helm Release for ALB Ingress Controller
resource "helm_release" "alb_ingress_controller" {
  name       = "alb-ingress-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "alb-ingress-controller"
  }

  set {
    name  = "region"
    value = "us-west-2"
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam.alb_ingress_controller_role_arn
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
- rolearn: ${module.iam.eks_worker_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${module.iam.alb_ingress_controller_role_arn}
  username: alb-ingress-controller
  groups:
    - system:masters
YAML
  }
}

# IAM Policy for EKS Cluster Description
resource "aws_iam_policy" "eks_describe_cluster_policy" {
  name        = "eks-describe-cluster-policy"
  description = "Policy to allow describing all EKS clusters"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "DescribeAllEksClusters",
        Effect   = "Allow",
        Action   = "eks:DescribeCluster",
        Resource = "*"
      },
      {
        "Sid" : "EKSAccessPolicy",
        "Effect" : "Allow",
        "Action" : [
          "eks:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Attach the policy to a user
resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = "mitesh_admin"
  policy_arn = aws_iam_policy.eks_describe_cluster_policy.arn
}

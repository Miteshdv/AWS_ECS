terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
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

module "eks" {
  source           = "./modules/eks"
  cluster_name     = "python-eks-cluster"
  cluster_role_arn = module.iam.eks_cluster_role_arn
  subnet_ids       = module.vpc.public_subnet_ids
}

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

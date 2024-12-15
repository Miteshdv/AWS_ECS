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

module "iam" {
  source             = "./modules/iam"
  dynamodb_table_arn = module.dynamodb.table_arn
}

# DynamoDB Module
module "dynamodb" {
  source        = "./modules/dynamo_db"
  table_name    = "eks-dynamodb-table"
  hash_key      = "id"
  hash_key_type = "S"
  tags = {
    Environment = "dev"
  }
}
resource "null_resource" "download_lambda_zip" {
  provisioner "local-exec" {
    command = "curl -L -o ./lambda-function-app.zip https://github.com/Miteshdv/eks_lambda/blob/main/lambda-function-app.zip"
  }
}

module "s3" {
  source        = "./modules/lambda_s3"
  bucket_name   = "eks-lambda-deployment-bucket"
  object_key    = "lambda/lambda-function-app.zip"
  object_source = "./lambda-function-app.zip"
  depends_on    = [null_resource.download_lambda_zip]
}

# Lambda Module
module "lambda" {
  source         = "./modules/lambda"
  function_name  = "eks-python-lambda-function"
  handler        = "lambda_function.lambda_handler"
  runtime        = "python3.8"
  role_arn       = module.iam.lambda_role_arn
  s3_bucket      = module.s3.bucket_name
  s3_key         = module.s3.object_key
  dynamodb_table = module.dynamodb.table_name
}



# API Gateway Module
module "api_gateway" {
  source            = "./modules/api_gateway"
  api_name          = "eks-api"
  api_description   = "EKS API Gateway"
  path_part         = "eks-gateway-resource"
  http_method       = "GET"
  stage_name        = "dev"
  lambda_invoke_arn = module.lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*/*"
}

resource "null_resource" "lambda_api_gateway_dependency" {
  depends_on = [
    aws_lambda_permission.apigw,
    module.api_gateway.aws_api_gateway_deployment
  ]
}


module "vpc" {
  source                    = "./modules/vpc"
  name                      = "ecs-vpc"
  cidr_block                = "10.0.0.0/16"
  public_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones        = ["us-west-2a", "us-west-2b"]
}

module "security_group" {
  source = "./modules/security"

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



# module "eks" {
#   source           = "./modules/eks"
#   cluster_name     = "python-eks-cluster"
#   cluster_role_arn = module.iam.eks_cluster_role_arn
#   subnet_ids       = module.vpc.public_subnet_ids
# }

# module "eks_workers" {
#   source               = "./modules/eks_workers"
#   cluster_name         = module.eks.cluster_name
#   image_id             = "ami-055e3d4f0bbeb5878" # Replace with your desired AMI ID
#   instance_type        = "t2.micro"
#   key_name             = var.key_name
#   security_groups      = [module.security_group.security_group_id]
#   subnet_ids           = module.vpc.public_subnet_ids
#   desired_capacity     = 2
#   max_size             = 3
#   min_size             = 1
#   iam_instance_profile = module.iam.eks_worker_profile_name
# }

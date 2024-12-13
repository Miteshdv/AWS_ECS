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
  source = "./modules/iam"
}


module "vpc" {
  source                   = "./modules/vpc"
  name                     = "ecs-vpc"
  cidr_block               = "10.0.0.0/16"
  public_subnet_cidr_block = "10.0.1.0/24"
  availability_zone        = "us-west-2a"
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



module "ec2" {
  source                      = "./modules/ec2"
  name_prefix                 = "python-server"
  image_id                    = "ami-055e3d4f0bbeb5878" # Replace with your desired AMI ID
  instance_type               = "t2.micro"
  device_name                 = "/dev/xvda"
  volume_size                 = 8
  volume_type                 = "gp2"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnet_id
  security_groups             = [module.security_group.security_group_id]
  key_name                    = var.key_name
  iam_instance_profile        = module.iam.instance_profile_name
  user_data                   = "user-data.sh"
  tags = {
    Name = "ec2-server-instance"
  }
}


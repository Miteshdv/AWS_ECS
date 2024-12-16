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

#resource "null_resource" "download_lambda_zip" {
#provisioner "local-exec" {
#command = "curl -L -o ./lambda-function-app.zip https://github.com/Miteshdv/eks_lambda/archive/refs/heads/main.zip"
#}
#}

module "s3" {
  source        = "./modules/lambda_s3"
  bucket_name   = "eks-lambda-deployment-bucket"
  object_key    = "lambda/lambda-function-app.zip"
  object_source = "./lambda-function-app.zip"
  #depends_on    = [null_resource.download_lambda_zip]
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

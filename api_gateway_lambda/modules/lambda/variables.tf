variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "Handler for the Lambda function"
  type        = string
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
}

variable "role_arn" {
  description = "IAM role ARN for the Lambda function"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket for the Lambda deployment package"
  type        = string
}

variable "s3_key" {
  description = "S3 key for the Lambda deployment package"
  type        = string
}

variable "dynamodb_table" {
  description = "DynamoDB table name"
  type        = string
}



variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
}

variable "path_part" {
  description = "Path part of the API Gateway resource"
  type        = string
}

variable "http_method" {
  description = "HTTP method for the API Gateway method"
  type        = string
}


variable "stage_name" {
  description = "Stage name for the API Gateway deployment"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "The ARN to invoke the Lambda function"
  type        = string
}

resource "aws_lambda_function" "eks_lambda" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table
    }
  }
}



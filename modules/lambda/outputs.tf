output "invoke_arn" {
  description = "The ARN to invoke the Lambda function"
  value       = aws_lambda_function.eks_lambda.invoke_arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.eks_lambda.function_name
}

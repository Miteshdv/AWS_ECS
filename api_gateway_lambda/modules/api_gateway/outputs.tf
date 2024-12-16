
output "rest_api_id" {
  description = "The ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api_gw.id
}

output "resource_id" {
  description = "The ID of the API Gateway resource"
  value       = aws_api_gateway_resource.resource.id
}

output "http_method" {
  description = "The HTTP method of the API Gateway method"
  value       = aws_api_gateway_method.method.http_method
}

output "execution_arn" {
  description = "The execution ARN of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api_gw.execution_arn
}

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.lambda_bucket.bucket
}

output "object_key" {
  description = "The key of the S3 object"
  value       = aws_s3_bucket_object.lambda_package.key
}

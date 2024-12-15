resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.bucket_name
  acl    = "private"
}


resource "aws_s3_bucket_object" "lambda_package" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = var.object_key
  source = var.object_source
}

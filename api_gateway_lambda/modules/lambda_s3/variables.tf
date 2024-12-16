
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "object_key" {
  description = "Key of the S3 object"
  type        = string
}

variable "object_source" {
  description = "Source URL of the S3 object"
  type        = string
}

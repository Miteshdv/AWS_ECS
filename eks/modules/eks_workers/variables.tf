variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "image_id" {
  description = "AMI ID for the worker nodes"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the worker nodes"
  type        = string
}

variable "key_name" {
  description = "Key name for SSH access"
  type        = string
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

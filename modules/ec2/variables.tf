variable "name_prefix" {
  description = "Prefix for the launch template name"
  type        = string
}

variable "image_id" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "device_name" {
  description = "Device name for the block device"
  type        = string
}

variable "volume_size" {
  description = "Size of the EBS volume"
  type        = number
}

variable "volume_type" {
  description = "Type of the EBS volume"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the instance"
  type        = map(string)
}



variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}



variable "key_name" {
  description = "Key name for SSH access"
  type        = string
}

variable "user_data" {
  description = "Path to the user data script"
  type        = string
}


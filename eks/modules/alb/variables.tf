variable "name" {
  description = "The name of the ALB"
  type        = string
}

variable "security_groups" {
  description = "The security group IDs for the ALB"
  type        = list(string)
}

variable "subnets" {
  description = "The subnet IDs for the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the EKS cluster role"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets"
  type        = list(string)
}

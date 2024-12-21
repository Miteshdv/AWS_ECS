variable "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The CA certificate of the EKS cluster"
  type        = string
}

variable "token" {
  description = "The token for authentication with the EKS cluster"
  type        = string
}

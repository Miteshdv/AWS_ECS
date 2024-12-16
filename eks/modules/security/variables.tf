variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "ingress_from_port" {
  description = "Ingress from port"
  type        = number
}

variable "ingress_to_port" {
  description = "Ingress to port"
  type        = number
}

variable "ingress_protocol" {
  description = "Ingress protocol"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "Ingress CIDR blocks"
  type        = list(string)
}

variable "egress_from_port" {
  description = "Egress from port"
  type        = number
}

variable "egress_to_port" {
  description = "Egress to port"
  type        = number
}

variable "egress_protocol" {
  description = "Egress protocol"
  type        = string
}

variable "egress_cidr_blocks" {
  description = "Egress CIDR blocks"
  type        = list(string)
}

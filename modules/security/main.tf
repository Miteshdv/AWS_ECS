resource "aws_security_group" "ec2_security-grp" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.ingress_from_port
    to_port     = var.ingress_to_port
    protocol    = var.ingress_protocol
    cidr_blocks = ["0.0.0.0/0"] # You can restrict this to specific IP ranges if needed
  }

  egress {
    from_port   = var.egress_from_port
    to_port     = var.egress_to_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }

  # Ingress rule to allow SSH access from anywhere
  ingress {
    description = "Allow SSH from EC2 Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # You can restrict this to specific IP ranges if needed
  }
}

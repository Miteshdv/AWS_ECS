resource "aws_launch_template" "ec2_lt" {
  name_prefix   = var.name_prefix
  image_id      = var.image_id
  instance_type = var.instance_type

  block_device_mappings {
    device_name = var.device_name

    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
    }
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = var.security_groups
  }

  tag_specifications {
    resource_type = "instance"

    tags = var.tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "ec2_instance" {
  ami                         = aws_launch_template.ec2_lt.image_id
  instance_type               = aws_launch_template.ec2_lt.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address

  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }
  tags = var.tags
}

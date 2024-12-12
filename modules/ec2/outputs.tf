output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.ec2_lt.id
}

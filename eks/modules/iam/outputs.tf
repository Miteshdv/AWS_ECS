output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_worker_profile_name" {
  description = "The name of the IAM instance profile for EKS workers"
  value       = aws_iam_instance_profile.eks_worker_profile.name
}


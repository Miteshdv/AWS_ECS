output "eks_cluster_role_name" {
  value = aws_iam_role.eks_cluster_role.name
}

output "eks_worker_profile_name" {
  value = aws_iam_instance_profile.eks_worker_profile.name
}

output "eks_worker_role_arn" {
  value = aws_iam_role.eks_worker_role.arn
}

output "alb_ingress_controller_role_arn" {
  value = aws_iam_role.alb_ingress_controller.arn
}

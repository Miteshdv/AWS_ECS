output "namespace" {
  value = kubernetes_namespace.python-eks-k8.metadata[0].name
}

output "deployment_name" {
  value = kubernetes_deployment.python-eks-k8.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.python-eks-k8.metadata[0].name
}

output "service_load_balancer_ingress" {
  value = kubernetes_service.python-eks-k8.status[0].load_balancer[0].ingress[0].hostname
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token                  = var.token
}

resource "kubernetes_namespace" "python-eks-k8" {
  metadata {
    name = "python-eks-k8"
  }
}

resource "kubernetes_deployment" "python-eks-k8" {
  metadata {
    name      = "python-eks-k8"
    namespace = kubernetes_namespace.python-eks-k8.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "python-eks-k8"
      }
    }

    template {
      metadata {
        labels = {
          app = "python-eks-k8"
        }
      }

      spec {
        container {
          name  = "python-eks-k8"
          image = "nginx:1.14.2"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "python-eks-k8" {
  metadata {
    name      = "python-eks-k8"
    namespace = kubernetes_namespace.python-eks-k8.metadata[0].name
  }

  spec {
    selector = {
      app = "python-eks-k8"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

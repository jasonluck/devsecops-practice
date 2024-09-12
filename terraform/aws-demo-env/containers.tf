###############################################################################
# EKS Containers
###############################################################################

resource "helm_release" "kubernetes_dashboard" {
  count = local.deploy_kubernetes_dashboard ? 1 : 0

  repository       = "https://kubernetes.github.io/dashboard"
  chart            = "kubernetes-dashboard"
  version          = "7.5.0"
  name             = "kubernetes-dashboard"
  namespace        = "kubernetes-dashboard"
  create_namespace = true

  set {
    name  = "kong.enabled"
    value = "false"
  }
}

# Create ALB for Kubernets Dashboard
resource "kubernetes_ingress_v1" "alb" {
  depends_on = [
    helm_release.alb-controller,
    helm_release.kubernetes_dashboard
  ]
  metadata {
    name      = "demo-ingress"
    namespace = "kubernetes-dashboard"
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/group.name"       = local.name
      "alb.ingress.kubernetes.io/scheme"           = "internal"
      "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kubernetes-dashboard-web"
              port {
                number = 8000
              }
            }
          }
        }
      }
    }
  }
}

###############################################################################
# Kubernetes Dashboard Application
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
    value = "true"
  }
  set {
    name  = "kong.proxy.http.enabled"
    value = "true"
  }
}

# Create ALB for Kubernets Dashboard
# There seems to be a bug around destroying this rresource
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/2335
# If destroy hangs on this resource, manually remove it from state using:
# terraform state rm "kubernetes_ingress_v1.alb[0]"
resource "kubernetes_ingress_v1" "alb" {
  count = local.deploy_kubernetes_dashboard ? 1 : 0
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
      "alb.ingress.kubernetes.io/group.name"       = local.cluster_name
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
              name = "kubernetes-dashboard-kong-proxy"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

##############################################################################
# Service Account for authenticating with dashboard
##############################################################################
resource "kubernetes_service_account_v1" "dashboard_admin" {
  count = local.deploy_kubernetes_dashboard ? 1 : 0
  metadata {
    name      = "dashboard-admin"
    namespace = "kubernetes-dashboard"
  }
}

resource "kubernetes_cluster_role_binding" "dashboard_admin" {
  count = local.deploy_kubernetes_dashboard ? 1 : 0
  metadata {
    name = "dashboard-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "dashboard-admin"
    namespace = "kubernetes-dashboard"
  }
}

resource "kubernetes_secret_v1" "dashboard_admin" {
  count = local.deploy_kubernetes_dashboard ? 1 : 0
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.dashboard_admin[0].metadata.0.name
    }
    name      = "dashboard-admin"
    namespace = "kubernetes-dashboard"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

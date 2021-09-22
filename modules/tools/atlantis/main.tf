resource "helm_release" "atlantis" {
  chart      = "atlantis"
  name       = "atlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  version    = "3.14.2"
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      default_terraform_version = var.default_terraform_version
      role_arn                  = var.role_arn
      ingress_hostname          = var.ingress_private_hostname
      ingress_class             = var.ingress_private_class
    })
  ]

  set_sensitive {
    name  = "github.token"
    value = var.github_token
  }

  set_sensitive {
    name  = "github.secret"
    value = var.github_webhook_secret
  }

  set_sensitive {
    name  = "github.user"
    value = var.github_username
  }
}

resource "kubernetes_ingress" "public_events_webhook" {
  metadata {
    name        = "atlantis-public-events-webhook"
    namespace   = helm_release.atlantis.namespace
    annotations = {
      "kubernetes.io/ingress.class": var.ingress_public_class
    }
  }
  spec {
    rule {
      host = var.ingress_public_hostname
      http {
        path {
          path = "/events"
          backend {
            service_name = "atlantis"
            service_port = 80
          }
        }
      }
    }
  }
}

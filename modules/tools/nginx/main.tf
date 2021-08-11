locals {
  name         = var.name == "" ? "ingress-nginx" : "ingress-nginx-${var.name}"
  min_replicas = 2
}

resource "helm_release" "nginx" {
  chart      = "ingress-nginx"
  name       = local.name
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "3.23.0"
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      cluster_wide                    = var.cluster_wide
      internal                        = var.internal
      default_certificate             = var.default_certificate
      service_type                    = var.service_type
      ingress_class                   = var.ingress_class
      ingress_external_traffic_policy = var.ingress_external_traffic_policy
      min_replicas                    = local.min_replicas
    })
  ]
}

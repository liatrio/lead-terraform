locals {
  name         = var.name == "" ? "ingress-nginx" : "ingress-nginx-${var.name}"
  min_replicas = 2
  extra_args   = var.default_certificate == "" ? var.extra_args : merge(var.extra_args, {
    default-ssl-certificate = var.default_certificate
  })
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
      extra_args                      = local.extra_args
      service_type                    = var.service_type
      ingress_class                   = var.ingress_class
      ingress_external_traffic_policy = var.ingress_external_traffic_policy
      min_replicas                    = local.min_replicas
    })
  ]
}

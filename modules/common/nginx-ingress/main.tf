data "template_file" "nginx_ingress_values" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/nginx-ingress-values.tpl")

  vars = {
    ingress_controller_type         = var.ingress_controller_type
    ingress_class                   = var.ingress_class
    ingress_external_traffic_policy = var.ingress_external_traffic_policy
    service_account                 = var.service_account
    cluster_wide                    = var.cluster_wide
    default_certificate             = var.default_certificate
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "nginx_ingress" {
  count      = var.enabled ? 1 : 0
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "nginx-ingress"
  version    = "1.33.5"
  namespace  = var.namespace
  name       = "nginx-ingress-${var.name}"
  timeout    = 600

  values = [data.template_file.nginx_ingress_values[0].rendered]
}


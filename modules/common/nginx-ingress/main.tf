resource "helm_release" "nginx_ingress" {
  count      = var.enabled ? 1 : 0
  repository = "https://charts.helm.sh/stable"
  chart      = "nginx-ingress"
  version    = "1.33.5"
  namespace  = var.namespace
  name       = "nginx-ingress-${var.name}"
  timeout    = 600

  values = [
    templatefile("${path.module}/nginx-ingress-values.tpl", {
      ingress_controller_type             = var.ingress_controller_type
      ingress_class                       = var.ingress_class
      ingress_external_traffic_policy     = var.ingress_external_traffic_policy
      service_account                     = var.service_account
      service_annotations                 = var.service_annotaitons
      service_load_balancer_source_ranges = var.service_load_balancer_source_ranges
      cluster_wide                        = var.cluster_wide
      default_certificate                 = var.default_certificate
    })
  ]
}


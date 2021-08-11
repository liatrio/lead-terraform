resource "helm_release" "rode" {
  repository = "https://harbor.toolchain.lead.prod.liatr.io/chartrepo/public"
  timeout    = 120
  name       = "rode"
  chart      = "rode"
  namespace  = var.namespace
  version    = "0.4.0"

  values = [
    templatefile("${path.module}/rode-values.tpl", {
      iam_arn            = var.rode_service_account_arn
      grafeas_cert       = "grafeas-cert"
      rode_cert          = "rode-cert"
      ingress_hostname   = "rode.${var.namespace}.${var.cluster}.${var.root_zone_name}"
      localstack_enabled = var.localstack_enabled
    })
  ]
}


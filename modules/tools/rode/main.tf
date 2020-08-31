data "helm_repository" "liatrio_harbor" {
  name = "liatrio-harbor"
  url  =  "https://harbor.toolchain.lead.prod.liatr.io/chartrepo/public"
}

resource "helm_release" "rode" {
  count      = var.enable_rode ? 1 : 0
  repository = data.helm_repository.liatrio_harbor.metadata[0].name
  timeout    = 120
  name       = "rode"
  chart      = "rode"
  namespace  = var.namespace

  values    = [
    templatefile("${path.module}/rode-values.tpl", {
      iam_arn      = var.rode_service_account_arn
      grafeas_cert = "grafeas-cert"
      rode_cert    = "rode-cert"
      ingress_hostname     = "rode.${var.namespace}.${var.cluster}.${var.root_zone_name}"
    })
  ]
}


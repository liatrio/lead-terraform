module "ca-issuer" {
  source = "../../common/ca-issuer"

  enabled          = var.enable_rode
  name             = "rode"
  namespace        = var.namespace
  common_name      = var.root_zone_name
  cert-manager-crd = var.crd_waiter
}

module "grafeas_certificate" {
  source = "../../common/certificates"

  enabled         = var.enable_rode
  name            = "grafeas-cert"
  namespace       = var.namespace
  domain          = "grafeas-server"
  issuer_name     = module.ca-issuer.name
  certificate_crd = var.crd_waiter
  wait_for_cert   = true
}

module "rode_certificate" {
  source = "../../common/certificates"

  enabled         = var.enable_rode
  name            = "rode-cert"
  namespace       = var.namespace
  domain          = "rode"
  issuer_name     = module.ca-issuer.name
  certificate_crd = var.crd_waiter
  wait_for_cert   = true
}

data "helm_repository" "liatrio-harbor" {
  name = "liatrio-harbor"
  url  =  "https://harbor.toolchain.lead.prod.liatr.io/chartrepo/public"
}

data "template_file" "rode_values" {
  template = file("${path.module}/rode-values.tpl")

  vars = {
    iam_arn              = var.rode_service_account_arn
    grafeas_cert         = module.grafeas_certificate.cert_name
    rode_cert            = module.rode_certificate.cert_name
  }
}

resource "helm_release" "rode" {
  count      = var.enable_rode ? 1 : 0
  repository = data.helm_repository.liatrio-harbor.metadata[0].name
  timeout    = 120
  name       = "rode"
  chart      = "rode"
  namespace  = var.namespace

  values = [
    data.template_file.rode_values.rendered
  ]
}


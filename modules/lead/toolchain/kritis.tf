module "ca-issuer" {
  source = "../../common/ca-issuer"

  name      = "kritis"
  namespace = var.namespace
  common_name = var.root_zone_name
  cert-manager-crd = var.crd_waiter
}

module "certificate" {
  source = "../../common/certificates"

  enabled = true
  name = "krits-cert"
  namespace = var.namespace
  domain = var.root_zone_name
  acme_enabled = false
  issuer_name = module.ca-issuer.name
}

resource "helm_release" "kritis" {
  name       = "kritis-server"
  namespace  = var.namespace
  chart      = "${path.module}/kritis-chart"
  version    = "0.1.1"
  timeout    = 600
  wait       = true

  depends_on = [module.certificate.cert_status]

  set {
    name = "certificates.name"
    value = "${module.certificate.cert_name}-certificate"
  }
}


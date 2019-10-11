module "ca-issuer" {
  source = "../../common/ca-issuer"

  name      = "grafeas"
  namespace = var.namespace
  common_name = var.root_zone_name
  cert-manager-crd = var.crd_waiter
}

module "certificate" {
  source = "../../common/certificates"

  enabled = true
  name = "grafeas-cert"
  namespace = var.namespace
  domain = var.root_zone_name
  acme_enabled = false
  issuer_name = module.ca-issuer.name
  certificate_crd = var.crd_waiter

}

resource "helm_release" "grafeas" {
  name       = "grafeas-server"
  namespace  = var.namespace
  chart      = "${path.module}/grafeas-chart"
  version    = "0.1.0"
  timeout    = 600
  wait       = true

  depends_on = [module.certificate.cert_status]

  set {
    name = "certificates.secretname"
    value = "${module.certificate.cert_name}-certificate"
  }
}

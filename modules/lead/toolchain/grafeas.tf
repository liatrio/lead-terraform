data "helm_repository" "liatrio-flywheel" {
  name = "lead.prod.liatr.io"
  url  = "https://artifactory.toolchain.lead.prod.liatr.io/artifactory/helm/"
}

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
  altname = "localhost"

}

resource "helm_release" "grafeas" {
  name       = "grafeas-server"
  repository = data.helm_repository.liatrio-flywheel.metadata[0].name
  namespace  = var.namespace
  chart      = "grafeas-server"
  version    = var.grafeas_version
  timeout    = 300 
  wait       = true

  depends_on = [module.certificate.cert_status]

  set {
    name = "certificates.secretname"
    value = "${module.certificate.cert_name}-certificate"
  }

  set {
    name = "grafeas_version"
    value = var.grafeas_version
  }
}

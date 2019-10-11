module "kritis_certificate" {
  source = "../../common/certificates"

  enabled = true
  name = "kritis-cert"
  namespace = var.namespace
  domain = var.root_zone_name
  acme_enabled = false
  issuer_name = module.ca-issuer.name
  certificate_crd = var.crd_waiter
}

resource "helm_release" "kritis-crd" {
  name       = "kritis-crd"
  namespace  = var.namespace
  chart      = "${path.module}/charts/kritis-crd"
  version    = "0.1.0"
  timeout    = 600
  wait       = true
}

data "kubernetes_secret" "kritis" {
  metadata {
    name = "${module.kritis_certficiate.cert_name}-certificate"
  }
}

resource "helm_release" "kritis" {
  name       = "kritis-server"
  namespace  = var.namespace
  chart      = "${path.module}/charts/kritis-chart"
  version    = "0.1.1"
  timeout    = 600
  wait       = true

  depends_on = [module.kritis_certificate.cert_status, helm_release.kritis-crd]

  set {
    name = "caBundle"
    value = lookup(data.kubernetes_secret.kritis.data, "tls.crt")
  }

  set {
    name = "certificates.name"
    value = "${module.kritis_certificate.cert_name}-certificate"
  }

  set {
    name = "tlsSecretName" 
    value = "${module.kritis_certificate.cert_name}-certificate"
  }

  set {
    name = "serviceNamespace"
    value = var.namespace
  }
}


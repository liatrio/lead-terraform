module "kritis_certificate" {
  source = "../../common/certificates"

  enabled = var.enable_grafeas
  name = "kritis-cert"
  namespace = var.namespace
  domain = "kritis-validation-hook.${var.namespace}.svc"
  acme_enabled = false
  issuer_name = module.ca-issuer.name
  certificate_crd = var.crd_waiter
  wait_for_cert = true
  cert_watcher_service_account = module.toolchain_namespace.certificate_watcher_service_account
}

resource "helm_release" "kritis-crd" {
  count      = var.enable_grafeas ? 1 : 0
  name       = "kritis-crd"
  namespace  = var.namespace
  chart      = "${path.module}/charts/kritis-crd"
  version    = "0.1.0"
  timeout    = 600
  wait       = true
}

data "kubernetes_secret" "kritis" {
  count      = var.enable_grafeas ? 1 : 0
  depends_on = [module.kritis_certificate.cert_status]
  metadata {
    name = "${module.kritis_certificate.cert_name}-certificate"
    namespace = var.namespace
  }
}

output "caBundle" {
  value = var.enable_grafeas ? "${base64encode(lookup(data.kubernetes_secret.kritis[0].data, "tls.crt"))}" : ""
}

resource "helm_release" "kritis" {
  count      = var.enable_grafeas ? 1 : 0
  name       = "kritis-server"
  namespace  = var.namespace
  chart      = "${path.module}/charts/kritis-chart"
  version    = "0.1.1"
  timeout    = 600
  wait       = true

  depends_on = [module.kritis_certificate.cert_status, helm_release.kritis-crd]

  set {
    name = "caBundle"
    value = "${base64encode(lookup(data.kubernetes_secret.kritis[count.index].data, "tls.crt"))}"
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


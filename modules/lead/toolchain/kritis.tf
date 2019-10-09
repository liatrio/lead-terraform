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


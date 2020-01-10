data "template_file" "certificate_values" {
  template = file("${path.module}/certificate-values.tpl")

  vars = {
    domain = var.domain
    altname = var.altname
    wait_for_cert = var.wait_for_cert
    issuer_name = var.issuer_name
    issuer_kind = var.issuer_kind
  }
}

resource "helm_release" "certificates" {
  count     = var.enabled ? 1 : 0
  name      = var.name
  namespace = var.namespace
  chart     = "${path.module}/helm/certificates"
  timeout   = 600
  wait      = true

  values = [data.template_file.certificate_values.rendered]

  depends_on = [var.certificate_crd]
}

data "template_file" "certificate_values" {
  template = file("${path.module}/certificate-values.tpl")

  vars = {
    domain = var.domain
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
}


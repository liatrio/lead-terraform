data "template_file" "istio_ingress_values" {
  template = file("${path.module}/istio-ingress-values.tpl")

  vars = {
    domain       = var.domain
    service_name = var.service_name
    service_port = var.service_port
  }
}

resource "helm_release" "istio_ingress" {
  count     = var.enabled ? 1 : 0
  name      = var.name
  namespace = var.namespace
  chart     = "${path.module}/helm/istio-ingress"
  timeout   = 600
  wait      = true

  values = [data.template_file.istio_ingress_values.rendered]
}

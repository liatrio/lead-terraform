#resource "helm_release" "certificates" {
#  count     = var.enabled ? 1 : 0
#  name      = var.name
#  namespace = var.namespace
#  chart     = "${path.module}/helm/certificates"
#  timeout   = 600
#  wait      = true
#
#  values = [templatefile("${path.module}/certificate-values.tpl", {
#    domain        = var.domain
#    altname       = var.altname
#    wait_for_cert = var.wait_for_cert
#    issuer_name   = var.issuer_name
#    issuer_kind   = var.issuer_kind
#  })]
#}

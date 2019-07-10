data "template_file" "issuer_values" {
  template = file("${path.module}/issuer-values.tpl")

  vars = {
    issuer_type = var.issuer_type
    crd_waiter  = var.crd_waiter # this enforces a dependency on the cert-manager CRDs
  }
}

resource "helm_release" "cert_manager_issuers" {
  name      = "cert-manager-issuers"
  namespace = var.namespace
  chart     = "${path.module}/helm/cert-manager-issuers"
  timeout   = 600
  wait      = true

  values = [data.template_file.issuer_values.rendered]
}


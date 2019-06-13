data "template_file" "issuer_values" {
  template = "${file("${path.module}/issuer-values.tpl")}"

  vars = {
    issuer_type = "${var.issuer_type}"
  }
}
resource "helm_release" "cert_manager_issuers" {
  name    = "cert-manager-issuers"
  namespace = "${kubernetes_namespace.ns.metadata.0.name}"
  chart   = "${path.module}/helm/cert-manager-issuers"
  timeout = 600
  wait    = true

  values = ["${data.template_file.issuer_values.rendered}"]
}
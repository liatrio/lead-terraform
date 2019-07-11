data "template_file" "certificate_values" {
  template = "${file("${path.module}/certificates-values.tpl")}"

  vars = {
    namespace = "${var.namespace}"
    cluster_domain = "${var.cluster_domain}"
  }
}
resource "helm_release" "certificates" {
  count = "${var.enabled ? 1 : 0}"
  name    = "certificates"
  namespace = "${var.namespace}"
  chart   = ".${replace(path.module, path.root, "")}/helm/certificates"
  timeout = 600
  wait    = true

  values = ["${data.template_file.certificate_values.rendered}"]
}


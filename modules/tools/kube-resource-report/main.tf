data "template_file" "kube_resource_report_values" {
  template = file("${path.module}/kube-resource-report-values.tpl")

  vars = {
    ssl_redirect     = var.root_zone_name == "localhost" ? false : true
    ingress_hostname = "kube-resource-report.${var.namespace}.${var.cluster}.${var.root_zone_name}"
  }
}

resource "helm_release" "kube_resource_report" {
  name       = "kube-resource-report"
  namespace  = var.namespace
  chart      = "${path.module}/chart/kube-resource-report"
  timeout    = 600
  wait       = true

  values = [data.template_file.kube_resource_report_values.rendered]
}

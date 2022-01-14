resource "helm_release" "kube_resource_report" {
  name      = "kube-resource-report"
  namespace = var.namespace
  chart     = "${path.module}/chart/kube-resource-report"
  timeout   = 600
  wait      = true

  values = [templatefile("${path.module}/kube-resource-report-values.tpl", {
    ssl_redirect     = var.root_zone_name == "localhost" ? false : true
    ingress_hostname = "kube-resource-report.${var.namespace}.${var.cluster}.${var.root_zone_name}"
  })]
}

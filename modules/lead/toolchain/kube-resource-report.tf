data "template_file" "kube_resource_report_values" {
  template = file("${path.module}/kube-resource-report-values.tpl")

  vars = {
    ssl_redirect     = var.root_zone_name == "localhost" ? false : true
    ingress_hostname = "kube-resource-report.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  }
}

resource "helm_release" "kube_resource_report" {
  name       = "kube-resource-report"
  namespace  = module.toolchain_namespace.name
  repository = data.helm_repository.liatrio.name
  chart      = "kube-resource-report"
  version    = "0.2.2"
  timeout    = 600
  wait       = true
  provider   = helm.toolchain

  depends_on = [data.helm_repository.liatrio]

  values = [data.template_file.kube_resource_report_values.rendered]
}

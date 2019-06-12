data "template_file" "k8s_dashboard_values" {
  template = "${file("${path.module}/k8s-dashboard-values.tpl")}"

  vars = {
    ingress_hostname = "kubernetes-dashboard.${var.namespace}.${var.cluster}.${var.root_zone_name}"
  }
}
resource "helm_release" "kubernetes_dashboard" {
  repository = "stable"
  chart      = "kubernetes-dashboard"
  namespace = "${module.toolchain_namespace.name}"
  name       = "kubernetes-dashboard"
  timeout    = 600
  wait       = true
  values = ["${data.template_file.k8s_dashboard_values.rendered}"]
}
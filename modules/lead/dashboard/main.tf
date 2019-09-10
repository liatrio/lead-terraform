data "template_file" "dashboard_values" {
  template = file("${path.module}/dashboard-values.tpl")

  vars = {
    cluster_domain = "${var.namespace}.${var.cluster}.${var.root_zone_name}"
    namespace = "${var.namespace}"
  }
}

data "helm_repository" "liatrio" {
  name = "lead.prod.liatr.io"
  url  = "https://artifactory.toolchain.lead.prod.liatr.io/artifactory/helm/"
}

resource "helm_release" "lead-dashboard" {
  repository = data.helm_repository.liatrio.metadata[0].name
  name       = "lead-dashboard"
  namespace  = var.namespace
  chart      = "lead-dashboard"
  version    = var.dashboard_version
  timeout    = 900

  values = [data.template_file.dashboard_values.rendered]
}

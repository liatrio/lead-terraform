data "template_file" "prometheus_values" {
  template = file("${path.module}/prometheus-values.tpl")
  
  vars = {
    prometheus_slack_webhook_url = var.prometheus_slack_webhook_url
    prometheus_slack_room = var.prometheus_slack_room
  }
}

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  namespace  = module.toolchain_namespace.name
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "prometheus-operator"
  version    = "8.3.3"
  timeout    = 600
  wait       = true

  values = [data.template_file.prometheus_values.rendered]

  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]
}
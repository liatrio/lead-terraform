data "template_file" "prometheus_values" {
  template = file("${path.module}/prometheus-values.tpl")
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = module.system_namespace.name
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "prometheus"
  version    = "8.14.0"
  timeout    = 600
  wait       = true

  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]

  values = [data.template_file.prometheus_values.rendered]
}

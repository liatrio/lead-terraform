data "template_file" "prometheus_values" {
  template = file("${path.module}/prometheus-values.tpl")
}

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  namespace  = module.toolchain_namespace.name
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "prometheus-operator"
  version    = "8.3.3"
  timeout    = 600
  wait       = true

  #values = [data.template_file.prometheus_values.rendered, var.essential_toleration_values]

  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]
}

data "template_file" "prometheus_values" {
  template = file("${path.module}/prometheus-values.tpl")
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}


resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  namespace  = module.toolchain_namespace.name
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "prometheus-operator"
  version    = "8.3.3"
  timeout    = 600
  wait       = true
  
  set {
    name = "grafana.adminPassword"
    value = random_password.password.result
  }

  #values = [data.template_file.prometheus_values.rendered, var.essential_toleration_values]

  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]
}

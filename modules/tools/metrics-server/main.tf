resource "helm_release" "metrics" {
  name       = "metrics-server"
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
  version    = "5.11.9"
  timeout    = 600
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      extra_values = var.extra_values
    })
  ]
}

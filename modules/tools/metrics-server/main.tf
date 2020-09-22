data "helm_repository" "bitnami" {
  name = "bitnami"
  url  = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "metrics" {
  name       = "metrics-server"
  namespace  = var.namespace
  repository = data.helm_repository.bitnami.metadata[0].name
  chart      = "metrics-server"
  version    = "4.3.2"
  timeout    = 600
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      extra_values  = var.extra_values
    })
  ]
}

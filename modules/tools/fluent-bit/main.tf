data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  namespace  = var.namespace
  chart      = "stable/fluent-bit"
  repository = data.helm_repository.stable.name
  version    = "2.8.13"
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      elasticsearch_username                 = var.elasticsearch_username
      elasticsearch_credentials_secret_name  = var.elasticsearch_credentials_secret_name
    })
  ]
}

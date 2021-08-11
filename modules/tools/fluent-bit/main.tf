resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  namespace  = var.namespace
  chart      = "fluent-bit"
  repository = "https://charts.helm.sh/stable"
  version    = "2.8.13"
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      elasticsearch_username                = var.elasticsearch_username
      elasticsearch_credentials_secret_name = var.elasticsearch_credentials_secret_name
    })
  ]
}

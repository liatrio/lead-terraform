resource "helm_release" "kibana" {
  name       = "kibana"
  namespace  = var.namespace
  chart      = "kibana"
  repository = "https://helm.elastic.co"
  version    = "7.6.2"
  wait       = true

  values = [
    templatefile("${path.module}/kibana-values.tpl", {
      elasticsearch_credentials_secret_name  = var.elasticsearch_credentials_secret_name
      elasticsearch_certificates_secret_name = var.elasticsearch_certificates_secret_name
    })
  ]
}

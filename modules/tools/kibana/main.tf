data "helm_repository" "elastic" {
  name = "elastic"
  url  = "https://helm.elastic.co"
}

resource "helm_release" "kibana" {
  name       = "kibana"
  namespace  = var.namespace
  chart      = "elastic/kibana"
  repository = data.helm_repository.elastic.name
  version    = "7.6.2"
  wait       = true

  values = [
    templatefile("${path.module}/kibana-values.tpl", {
      elasticsearch_credentials_secret_name  = var.elasticsearch_credentials_secret_name
      elasticsearch_certificates_secret_name = var.elasticsearch_certificates_secret_name
    })
  ]
}

// Keycloak Gatekeeper config

//data "kubernetes_secret" "keycloak_admin_credential" {
//  count = var.enable_keycloak ? 1 : 0
//
//  metadata {
//    name      = var.keycloak_admin_credential_secret
//    namespace = var.toolchain_namespace
//  }
//}

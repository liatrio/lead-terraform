resource "kubernetes_secret" "keycloak_credentials" {
  metadata {
    name      = "keycloak-credentials"
    namespace = var.namespace
  }
  type = "Opaque"

  data = {
    admin_username = "keycloak"
    admin_password = var.keycloak_admin_password
  }
}

resource "helm_release" "keycloak" {
  repository = "https://codecentric.github.io/helm-charts"
  name       = "keycloak"
  namespace  = var.namespace
  chart      = "keycloak"
  version    = "9.0.5"
  timeout    = 1200

  values = [
    templatefile("${path.module}/values.tpl", {
      ingress_class    = var.ingress_class
      ingress_hostname = "keycloak.${var.cluster_domain}"
      keycloak_secret  = kubernetes_secret.keycloak_credentials.metadata[0].name
    })
  ]

  set_sensitive {
    name  = "postgresql.postgresqlPassword"
    value = var.postgres_password
  }
}

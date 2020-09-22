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
  count      = var.enable_keycloak ? 1 : 0

  repository = "https://codecentric.github.io/helm-charts"
  name       = "keycloak"
  namespace  = var.namespace
  chart      = "keycloak"
  version    = "9.0.5"
  timeout    = 1200

  values = [
    templatefile("${path.module}/values.tpl", {
      ssl_redirect     = var.root_zone_name == "localhost" ? false : true
      cluster_domain   = "${var.cluster}.${var.root_zone_name}"
      ingress_hostname = "keycloak.${var.namespace}.${var.cluster}.${var.root_zone_name}"
      keycloak_secret  = kubernetes_secret.keycloak_credentials.metadata[0].name
    })
  ]

  set_sensitive {
    name  = "postgresql.postgresqlPassword"
    value = var.postgres_password
  }
}

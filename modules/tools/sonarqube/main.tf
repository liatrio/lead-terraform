resource "helm_release" "sonarqube" {
  repository = "https://oteemo.github.io/charts"
  name       = "sonarqube"
  namespace  = var.namespace
  chart      = "sonarqube"
  version    = "9.6.3"
  timeout    = 1200
  wait       = true

  set_sensitive {
    name  = "postgresql.postgresPassword"
    value = var.postgres_password
  }

  set_sensitive {
    name  = "account.adminPassword"
    value = var.admin_password
  }

  set_sensitive {
    name  = "account.currentAdminPassword"
    value = "admin"
  }

  set_sensitive {
    name  = "sonarProperties.sonar\\.auth\\.oidc\\.clientSecret\\.secured"
    value = var.keycloak_client_secret
  }

  values = [
    templatefile("${path.module}/sonarqube-values.tpl", {
      ingress_enabled      = var.ingress_enabled
      ingress_hostname     = var.ingress_hostname
      ingress_annotations  = var.ingress_annotations
      force_authentication = var.force_authentication
      enable_keycloak      = var.enable_keycloak
      keycloak_issuer_uri  = var.keycloak_issuer_uri
      keycloak_client_id   = var.keycloak_client_id
    })
  ]
}

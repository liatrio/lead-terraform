data "helm_repository" "codecentric" {
  name = "codecentric"
  url  = "https://codecentric.github.io/helm-charts"
}

resource "helm_release" "keycloak" {
  count      = var.enable_keycloak ? 1 : 0

  repository = data.helm_repository.codecentric.name
  name       = "keycloak"
  namespace  = var.namespace
  chart      = "keycloak"
  version    = "5.0.1"
  timeout    = 1200

  values = [
    templatefile("${path.module}/values.tpl", {
      ssl_redirect     = var.root_zone_name == "localhost" ? false : true
      cluster_domain   = "${var.cluster}.${var.root_zone_name}"
      ingress_hostname = "keycloak.${var.namespace}.${var.cluster}.${var.root_zone_name}"
    })
  ]

  set_sensitive {
    name  = "postgresql.postgresqlPassword"
    value = var.postgres_password
  }
}

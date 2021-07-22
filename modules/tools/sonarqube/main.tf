resource "helm_release" "sonarqube" {
  count      = var.enable_sonarqube ? 1 : 0
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

  values = [
    templatefile("${path.module}/sonarqube-values.tpl", {
      ingress_enabled     = var.ingress_enabled
      ingress_hostname    = var.ingress_hostname
      ingress_annotations = var.ingress_annotations
    })
  ]
}

resource "random_password" "postgres_admin_password" {
  length  = 16
  special = false
}

resource "helm_release" "artifactory_jcr" {
  repository = "https://repo.chartcenter.io"
  name       = "jfrog-container-registry"
  namespace  = var.namespace
  chart      = "jfrog/artifactory-jcr"
  version    = "3.6.0"

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      ingress_enabled = true
      artifactory_jcr_hostname = var.hostname
      jcr_admin_password = var.jcr_admin_password
    })
  ]

  set_sensitive {
    name  = "postgresql.postgresqlPassword"
    value = data.random_password.postgres_admin_password.result
  }
}

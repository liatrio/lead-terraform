resource "random_password" "postgres_admin_password" {
  length  = 16
  special = false
}

resource "kubernetes_config_map" "artifactory_eula_config" {
  metadata {
    name      = "artifactory-eula-config"
    namespace = var.namespace
  }
  data = {
    "artifactory.config.import.yml" = file("${path.module}/artifactory_config.yaml")
  }
}

resource "kubernetes_secret" "artifactory_jcr_credentials" {
  metadata {
    name      = "artifactory-jcr-credentials"
    namespace = var.namespace
  }

  data = {
    username = "admin"
    password = var.jcr_admin_password
  }
}

resource "helm_release" "artifactory_jcr" {
  repository = "https://repo.chartcenter.io"
  name       = "jfrog-container-registry"
  namespace  = var.namespace
  chart      = "jfrog/artifactory-jcr"
  version    = "3.6.0"

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      ingress_enabled          = true
      artifactory_jcr_hostname = var.hostname
    })
  ]

  set_sensitive {
    name  = "artifactory.artifactory.admin.password"
    value = kubernetes_secret.artifactory_jcr_credentials.data.password
  }

  set_sensitive {
    name  = "artifactory.postgresql.postgresqlPassword"
    value = random_password.postgres_admin_password.result
  }

  depends_on = [
    kubernetes_config_map.artifactory_eula_config,
  ]
}

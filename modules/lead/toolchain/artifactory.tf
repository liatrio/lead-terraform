
resource "random_string" "artifactory_admin_password" {
  length  = 10
  special = false
}

resource "random_string" "artifactory_db_password" {
  length  = 10
  special = false
 }

data "helm_repository" "jfrog" {
  name = "jfrog"
  url  = "https://charts.jfrog.io"
}

resource "helm_release" "artifactory" {
  repository = "jfrog"
  name       = "artifactory"
  namespace  = "${module.toolchain_namespace.name}"
  chart      = "artifactory"
  version    = "7.14.3"
  timeout    = 1200

  set {
    name  = "nginx.enabled"
    value = "false"
  }

  set_sensitive {
    name  = "artifactory.license.licenseKey"
    value = "${var.artifactory_license}"
  }

  set_sensitive {
     name  = "postgresql.postgresPassword"
     value = "${random_string.artifactory_db_password.result}"
   }

  set_sensitive {
   name  = "artifactory.accessAdmin.password"
   value = "${random_string.artifactory_admin_password.result}"
  }
}

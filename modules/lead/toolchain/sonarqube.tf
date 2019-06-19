resource "random_string" "sonarqube_db_password" {
  length  = 10
  special = false
 }

resource "helm_release" "sonarqube" {
  repository = "stable"
  name       = "sonarqube"
  namespace  = "${module.toolchain_namespace.name}"
  chart      = "sonarqube"
  version    = "2.0.0"
  timeout    = 1200

  set {
    name  = "ingress.enabled"
    value = "false"
  }

  set {
    name = "service.type"
    value = "ClusterIP"
  }

  set_sensitive {
     name  = "postgresql.postgresPassword"
     value = "${random_string.sonarqube_db_password.result}"
  }

}

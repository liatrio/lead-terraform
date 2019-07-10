resource "random_string" "sonarqube_db_password" {
  length  = 10
  special = false
}

resource "random_string" "sonar_jenkins_password" {
  length  = 10
  special = false
}

resource "helm_release" "sonarqube" {
  repository = "stable"
  name       = "sonarqube"
  namespace  = module.toolchain_namespace.name
  chart      = "sonarqube"
  version    = "2.0.0"
  timeout    = 1200
  wait       = true

  set {
    name  = "ingress.enabled"
    value = "false"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set_sensitive {
    name  = "postgresql.postgresPassword"
    value = random_string.sonarqube_db_password.result
  }
}

resource "kubernetes_secret" "jenkins_sonar" {
  metadata {
    name      = "jenkins-sonarqube-credential"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins.io/credentials-type"  = "usernamePassword"
    }
  }

  type = "Opaque"

  data = {
    #    username = "jenkins"
    #    password = "${random_string.sonar_jenkins_password.result}"
    username = "admin"
    password = "admin"
  }
}


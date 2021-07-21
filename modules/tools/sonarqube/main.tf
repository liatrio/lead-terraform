resource "random_string" "sonarqube_db_password" {
  length  = 10
  special = false
}

data "template_file" "sonarqube_values" {
  template = file("${path.module}/sonarqube-values.tpl")
}

resource "helm_release" "sonarqube" {
  count      = var.enable_sonarqube ? 1 : 0
  repository = "https://oteemo.github.io/charts"
  name       = "sonarqube"
  namespace  = var.namespace
  chart      = "sonarqube"
  version    = "9.6.3"
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

  values = [data.template_file.sonarqube_values.rendered]
}

resource "kubernetes_secret" "jenkins_sonar" {
  metadata {
    name      = "jenkins-sonarqube-credential"
    namespace = var.namespace

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

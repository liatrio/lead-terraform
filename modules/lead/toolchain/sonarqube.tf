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
  namespace  = "${module.toolchain_namespace.name}"
  chart      = "sonarqube"
  version    = "2.0.0"
  timeout    = 1200
  wait       = true

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

resource "null_resource" "jenkins_user" {
  depends_on = ["helm_release.sonarqube"]
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    sonarqube = "${helm_release.sonarqube.name}"
  }

  provisioner "local-exec" {
    command = <<EOT
    kubectl -n "${module.toolchain_namespace.name}" port-forward service/sonarqube-sonarqube 9000 &
    sleep 120
    curl -X POST -v \
    -u admin:admin \
    -d email="jenkins@${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}" \
    -d login=jenkins \
    -d password="${random_string.sonar_jenkins_password.result}" \
    -d name=jenkins \
    "http://localhost:9000/api/users/create"
    sleep 2
    kill %1
    EOT
  }
}


resource "kubernetes_secret" "jenkins_sonar" {
  metadata {
    name      = "jenkins-sonarqube-credential"
    namespace = "${var.namespace}"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins.io/credentials-type"  = "usernamePassword"
    }
  }

  type = "Opaque"

  data {
    username = "jenkins"
    password = "${random_string.sonar_jenkins_password.result}"
  }
}

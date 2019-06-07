data "template_file" "artifactory_security_values" {
  template = "${file("${path.module}/artifactory.security.import.xml.tpl")}"
  vars = {
    # To prefix bcrypt strings with 'bcrypt$', we use format here due to escape issues in template.
    jenkins_bcrypt_pass = "${format("bcrypt$%s", bcrypt(random_string.artifactory_jenkins_password.result))}"
    admin_bcrypt_pass   = "${format("bcrypt$%s", bcrypt(random_string.artifactory_admin_password.result))}"
  }
}

data "template_file" "artifactory_config_values" {
  template = "${file("${path.module}/artifactory.config.import.xml.tpl")}"
}

resource "kubernetes_secret" "artifactory_admin" {
  metadata {
    name      = "artifactory-admin-credential"
    namespace = "${var.namespace}"
  }
  type = "Opaque"

  data {
    username = "admin"
    password = "${random_string.artifactory_admin_password.result}"
  }
}

resource "kubernetes_secret" "artifactory_jenkins" {
  metadata {
    name      = "jenkins-artifactory-credential"
    namespace = "${var.namespace}"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins.io/credentials-type"  = "usernamePassword"
    }

    annotations {
      "source-repo"                        = "https://github.com/liatrio/lead-toolchain"
      "jenkins.io/credentials-description" = "Artifactory Credentials"
    }
  }

  type = "Opaque"

  data {
    username = "jenkins"
    password = "${random_string.artifactory_jenkins_password.result}"
  }
}

resource "kubernetes_config_map" "artifactory_config" {
  metadata {
    name = "lead-bootstrap-artifactory-config"
    namespace = "${var.namespace}"
  }

  data {
    artifactory.config.import.xml = "${data.template_file.artifactory_config_values.rendered}"
  }

  data {
    security.import.xml = "${data.template_file.artifactory_security_values.rendered}"
  }
}

resource "random_string" "artifactory_jenkins_password" {
  length  = 10
  special = false
}

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
  depends_on = ["kubernetes_config_map.artifactory_config"]
  repository = "jfrog"
  name       = "artifactory"
  namespace  = "${module.toolchain_namespace.name}"
  chart      = "artifactory"
  version    = "7.14.3"
  timeout    = 1200

  set {
    name  = "artifactory.configMapName"
    value = "lead-bootstrap-artifactory-config"
  }

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

  // set_sensitive {
  //  name  = "artifactory.accessAdmin.password"
  //  value = "${random_string.artifactory_admin_password.result}"
  // }
}

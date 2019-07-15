data "template_file" "artifactory_security_values" {
  template = file("${path.module}/artifactory.security.import.xml.tpl")
  vars = {
    # To prefix bcrypt strings with 'bcrypt$', we use format here due to escape issues in template.
    jenkins_bcrypt_pass = format(
      "bcrypt$%s",
      bcrypt(random_string.artifactory_jenkins_password.result),
    )
    admin_bcrypt_pass = format(
      "bcrypt$%s",
      bcrypt(random_string.artifactory_admin_password.result),
    )
  }
}

data "template_file" "artifactory_config_values" {
  template = file("${path.module}/artifactory.config.import.xml.tpl")

  vars = {
    server_name = "artifactory.${var.namespace}.${var.cluster}.${var.root_zone_name}"
  }
}

resource "kubernetes_secret" "artifactory_admin" {
  metadata {
    name      = "artifactory-admin-credential"
    namespace = module.toolchain_namespace.name
  }
  type = "Opaque"

  data = {
    username = "admin"
    password = random_string.artifactory_admin_password.result
  }
}

resource "kubernetes_secret" "artifactory_jenkins" {
  metadata {
    name      = "jenkins-artifactory-credential"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins.io/credentials-type"  = "usernamePassword"
    }

    annotations = {
      "source-repo"                        = "https://github.com/liatrio/lead-toolchain"
      "jenkins.io/credentials-description" = "Artifactory Credentials"
    }
  }

  type = "Opaque"

  data = {
    username = "jenkins"
    password = random_string.artifactory_jenkins_password.result
  }
}

resource "kubernetes_config_map" "artifactory_config" {
  metadata {
    name      = "lead-bootstrap-artifactory-config"
    namespace = module.toolchain_namespace.name
  }

  data = {
    "artifactory.config.import.xml" = data.template_file.artifactory_config_values.rendered
    "security.import.xml" = data.template_file.artifactory_security_values.rendered
  }

  lifecycle {
    # issues with using bcrypt generated passwords, which will always create a new value

    # even with ignoring all or data, the apply still reads updated data and presents a prompt
    # to apply, even with "Plan: 0 to add, 1 to change, 0 to destroy."
    # similar to https://github.com/hashicorp/terraform/issues/21663
    #ignore_changes = all
    ignore_changes = [data]

    # issues with ignoring this, mainly due to periods in the key name
    # https://github.com/hashicorp/terraform/issues/21857
    # https://github.com/hashicorp/terraform/issues/21433
    #ignore_changes = [data["security.import.xml"]]
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

data "template_file" "artifactory_values" {
  template = file("${path.module}/artifactory-values.tpl")

  vars = {
    ingress_hostname = "artifactory.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  }
}

resource "helm_release" "artifactory" {
  count      = var.enable_artifactory ? 1 : 0
  depends_on = [kubernetes_config_map.artifactory_config]
  repository = data.helm_repository.jfrog.metadata[0].name
  name       = "artifactory"
  namespace  = module.toolchain_namespace.name
  chart      = "artifactory"
  version    = "7.14.3"
  timeout    = 1200

  set {
    name  = "artifactory.configMapName"
    value = "lead-bootstrap-artifactory-config"
  }

  set {
    name = "artifactory.persistence.size"
    value = "100Gi"
  }

  set {
    name  = "nginx.enabled"
    value = "false"
  }

  set_sensitive {
    name  = "artifactory.license.licenseKey"
    value = var.artifactory_license
  }

  set_sensitive {
    name  = "postgresql.postgresPassword"
    value = random_string.artifactory_db_password.result
  }

  values = [data.template_file.artifactory_values.rendered]
}


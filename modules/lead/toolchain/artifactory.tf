resource "kubernetes_secret" "artifactory_admin" {
  count = var.enable_artifactory ? 1 : 0
  metadata {
    name      = "artifactory-admin-credential"
    namespace = module.toolchain_namespace.name
  }
  type = "Opaque"

  data = {
    username = "admin"
    password = random_string.artifactory_admin_password[0].result
  }
}

resource "kubernetes_secret" "artifactory_jenkins" {
  count = var.enable_artifactory ? 1 : 0
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
    password = random_string.artifactory_jenkins_password[0].result
  }
}

resource "kubernetes_config_map" "artifactory_config" {
  count = var.enable_artifactory ? 1 : 0
  metadata {
    name      = "lead-bootstrap-artifactory-config"
    namespace = module.toolchain_namespace.name
  }

  data = {
    "artifactory.config.import.xml" = templatefile("${path.module}/artifactory.config.import.xml.tpl", {
      server_name = "artifactory.${var.namespace}.${var.cluster}.${var.root_zone_name}"
    })
    "security.import.xml" = templatefile("${path.module}/artifactory.security.import.xml.tpl", {
      # To prefix bcrypt strings with 'bcrypt$', we use format here due to escape issues in template.
      jenkins_bcrypt_pass = format(
        "bcrypt$%s",
        bcrypt(random_string.artifactory_jenkins_password[0].result),
      )
      admin_bcrypt_pass = format(
        "bcrypt$%s",
        bcrypt(random_string.artifactory_admin_password[0].result),
      )
    })
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
  count   = var.enable_artifactory ? 1 : 0
  length  = 10
  special = false
}

resource "random_string" "artifactory_admin_password" {
  count   = var.enable_artifactory ? 1 : 0
  length  = 10
  special = false
}

resource "random_string" "artifactory_db_password" {
  count   = var.enable_artifactory ? 1 : 0
  length  = 10
  special = false
}

resource "helm_release" "artifactory" {
  count      = var.enable_artifactory ? 1 : 0
  depends_on = [kubernetes_config_map.artifactory_config]
  repository = "https://charts.jfrog.io"
  name       = "artifactory"
  namespace  = module.toolchain_namespace.name
  chart      = "artifactory"
  version    = "8.5.1"
  timeout    = 1200

  set {
    name  = "artifactory.configMapName"
    value = "lead-bootstrap-artifactory-config"
  }

  set {
    name  = "artifactory.persistence.size"
    value = "200Gi"
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
    value = random_string.artifactory_db_password[0].result
  }

  values = [templatefile("${path.module}/artifactory-values.tpl", {
    ssl_redirect     = var.root_zone_name == "localhost" ? false : true
    ingress_hostname = "artifactory.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  })]

  # We would like to ignore changes on artifactory.persistence.size, but currently there's
  # a limitation in Terraform because set members are not individually addressible
  # (see https://github.com/hashicorp/terraform/issues/22504), so we're just ignoring
  # all changes for Artifactory. Alternative is to do the configuration of the PVC
  # separately and point the chart to the existing PVC.
  lifecycle {
    ignore_changes = all
  }

}


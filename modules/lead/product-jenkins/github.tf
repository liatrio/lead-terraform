locals {
  enable_github_credentials = var.jenkins_pipeline_source == "github" ? 1 : 0
}

data "kubernetes_secret" "github_creds" {
  count    = local.enable_github_credentials
  provider = kubernetes.toolchain

  metadata {
    name      = "github-credentials"
    namespace = var.toolchain_namespace
  }
}

resource "kubernetes_secret" "github" {
  count    = local.enable_github_credentials
  provider = kubernetes.toolchain

  metadata {
    name        = "jenkins-credential-github"
    namespace   = module.toolchain_namespace.name
    labels      = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins.io/credentials-type"  = "usernamePassword"
    }
    annotations = {
      "source-repo"                        = "https://github.com/liatrio/lead-envirnoment"
      "jenkins.io/credentials-description" = "GitHub Credentials"
    }
  }
  type = "Opaque"
  data = {
    username = data.kubernetes_secret.github_creds[0].data["username"]
    password = data.kubernetes_secret.github_creds[0].data
  }
}

resource "kubernetes_secret" "github_token" {
  count    = local.enable_github_credentials
  provider = kubernetes.toolchain

  metadata {
    name        = "jenkins-credential-github-token"
    namespace   = module.toolchain_namespace.name
    labels      = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins.io/credentials-type"  = "secretText"
    }
    annotations = {
      "source-repo"                        = "https://github.com/liatrio/lead-envirnoment"
      "jenkins.io/credentials-description" = "GitHub Credentials"
    }
  }
  type = "Opaque"
  data = {
    text = data.kubernetes_secret.github_creds[0].data["token"]
  }
}

resource "kubernetes_config_map" "jcasc_github_plugin" {
  count    = local.enable_github_credentials
  provider = kubernetes.toolchain

  metadata {
    name      = "jenkins-jenkins-config-github-plugin"
    namespace = module.toolchain_namespace.name
    labels    = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins-jenkins-config"       = "true"
    }
  }
  data = {
    "github-plugin.yaml" = templatefile("${path.module}/github.tpl", {
      secret_name = kubernetes_secret.github_token[0].metadata[0].name
    })
  }
}

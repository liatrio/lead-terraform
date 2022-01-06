locals {
  artifactory_user = length(data.kubernetes_secret.artifactory_jcr_credentials) == 1 ? data.kubernetes_secret.artifactory_jcr_credentials[0].data.username : ""
  artifactory_pass = length(data.kubernetes_secret.artifactory_jcr_credentials) == 1 ? data.kubernetes_secret.artifactory_jcr_credentials[0].data.password : ""
  harbor_pass      = var.enable_harbor ? harbor_robot_account.robot[0].token : ""
  config_json = templatefile("${path.module}/dockercfg.tpl", {
    email           = "jenkins@liatr.io"
    artifactory_url = "https://artifactory-jcr.toolchain.${var.cluster_domain}/general-docker"
    artifactory_auth = base64encode(
    "${local.artifactory_user}:${local.artifactory_pass}",
    )
    harbor_url = "https://harbor.toolchain.${var.cluster_domain}/${var.product_name}"
    harbor_auth = base64encode(
    "robot$imagepusher:${local.harbor_pass}",
    )
    enable_harbor = var.enable_harbor
  })
}

resource "kubernetes_secret" "jenkins_repository_dockercfg" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-repository-dockercfg"
    namespace = module.toolchain_namespace.name
  }

  data = {
    "config.json" = local.config_json
  }

  type = "Opaque"
}

resource "kubernetes_secret" "prod_image_pull_secrets" {
  provider = kubernetes.production
  metadata {
    name      = "image-pull-secret"
    namespace = module.product_base.production_namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = local.config_json
  }
}

resource "kubernetes_secret" "staging_image_pull_secrets" {
  provider = kubernetes.staging
  metadata {
    name      = "image-pull-secret"
    namespace = module.product_base.staging_namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = local.config_json
  }
}

locals {
  ingress_hostname      = "${var.github_org}-webhook.${var.ingress_domain}"
  release_name          = var.release_name != "" ? var.release_name : "${var.github_org}-runner-controller"
  auth_secret_full_name = "${local.release_name}-${var.auth_secret_name}"
}

module "github_runner_controller_namespace" {
  source = "../../common/namespace"

  namespace = var.namespace
}

resource "kubernetes_secret" "github_app" {
  metadata {
    name      = local.auth_secret_full_name
    namespace = module.github_runner_controller_namespace.name
  }

  data = {
    github_app_id : var.github_app_id
    github_app_installation_id : var.github_app_installation_id
    github_app_private_key : var.github_app_private_key
  }
}

resource "kubernetes_secret" "github_webhook_server" {
  metadata {
    name      = "github-webhook-server"
    namespace = module.github_runner_controller_namespace.name
  }

  data = {
    github_webhook_secret_token = var.github_webhook_secret_token
  }
}

resource "helm_release" "github_runner_controller" {
  name       = local.release_name
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  version    = "0.12.7"
  namespace  = module.github_runner_controller_namespace.name
  wait       = true

  values = [
    templatefile("${path.module}/runner-controller-values.tpl", {
      secret_name : local.auth_secret_full_name
      controller_replica_count : var.controller_replica_count
      ingress_hostname : local.ingress_hostname
      github_webhook_annotations : var.github_webhook_annotations
    })
  ]

  depends_on = [kubernetes_secret.github_app, kubernetes_secret.github_webhook_server]
}


locals {
  ingress_hostname = "${var.github_org}-webhook.${var.namespace}.${var.cluster_domain}"
  release_name = var.release_name != "" ? var.release_name : "${var.github_org}-runner-controller"
  auth_secret_full_name = "${local.release_name}-${var.auth_secret_name}"
}

module github_runner_controller_namespace {
  source = "../../common/namespace"

  namespace = var.namespace
}

resource kubernetes_secret github_app {
  metadata {
    name      = local.auth_secret_full_name
    namespace = module.github_runner_controller_namespace.name
  }

  data = {
    github_app_id: var.github_app_id
    github_app_installation_id: var.github_app_installation_id
    github_app_private_key: var.github_app_private_key
  }
}

resource helm_release github_runner_controller {
  name       = local.release_name
  repository = "https://summerwind.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  version    = "0.9.0"
  namespace  = module.github_runner_controller_namespace.name
  wait       = true

  values = [
    templatefile("${path.module}/runner-controller-values.tpl", {
      secret_name: local.auth_secret_full_name
      controller_replica_count = var.controller_replica_count
      runner_autoscaling_enabled: var.runner_autoscaling_enabled
      runner_autoscaling_min_replicas: var.runner_autoscaling_min_replicas
      runner_autoscaling_max_replicas: var.runner_autoscaling_max_replicas
      runner_autoscaling_cpu_util: var.runner_autoscaling_cpu_util
      ingress_hostname: local.ingress_hostname
    })
  ]

  depends_on = [kubernetes_secret.github_app]
}


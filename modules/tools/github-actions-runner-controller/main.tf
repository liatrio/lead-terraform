locals {
  auth_secret_full_name = "${var.deployment_name}-${var.auth_secret_name}"
}

module github_runners_namespace {
  source = "../../common/namespace"

  namespace = "github-runners"
}

resource kubernetes_secret github_app {
  metadata {
    name      = local.auth_secret_full_name
    namespace = module.github_runners_namespace.name
  }

  data = {
    github_app_id: var.github_app_id
    github_app_installation_id: var.github_app_installation_id
    github_app_private_key: var.github_app_private_key
  }
}

resource helm_release github_runners {
  name       = var.deployment_name
  repository = "https://summerwind.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  version    = "0.9.0"
  namespace  = module.github_runners_namespace.name
  wait       = true

  values = [
    templatefile("${path.module}/github-runners-values.tpl", {
      secret_name: local.auth_secret_full_name
      controller_replica_count = var.controller_replica_count
      runner_autoscaling_enabled: var.runner_autoscaling_enabled
      runner_autoscaling_min_replicas: var.runner_autoscaling_min_replicas
      runner_autoscaling_max_replicas: var.runner_autoscaling_max_replicas
      runner_autoscaling_cpu_util: var.runner_autoscaling_cpu_util

    })
  ]

  depends_on = [kubernetes_secret.github_app]
}


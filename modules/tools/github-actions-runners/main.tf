locals {
  release_name = var.github_org != "" ? "${var.github_org}-runners" : "${replace(var.github_repo, "/", "-")}-runners"
}

resource "helm_release" "github_runners" {
  name      = local.release_name
  chart     = "${path.module}/github-actions-runners"
  namespace = var.namespace
  wait      = true

  values = [
    templatefile("${path.module}/runner-values.tpl", {
      github_org                = var.github_org
      github_repo               = var.github_repo
      image                     = var.image
      labels                    = var.labels
      runner_annotations        = var.github_runners_service_account_annotations
      autoscaler_min_replicas   = var.runner_autoscaler_min_replicas
      autoscaler_max_replicas   = var.runner_autoscaler_max_replicas
      autoscaler_scale_amount   = var.runner_autoscaler_scale_ammount
      autoscaler_scale_duration = var.runner_autoscaler_scale_duration
      service_account_name      = local.release_name
    })
  ]
}

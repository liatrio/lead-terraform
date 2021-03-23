resource helm_release github_runner_controller {
  name      = var.release_name
  chart     = "./github-actions-runners"
  namespace = var.namespace
  wait      = true

  values = [
    templatefile("${path.module}/runner-values.tpl", {
      github_org    = var.github_org
      runner_labels = yamlencode(length(var.runner_labels) > 0 ? {runner_labels: var.runner_labels} : {})
    })
  ]
}


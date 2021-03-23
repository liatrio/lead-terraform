locals {
  release_name = var.release_name != "" ? var.release_name : "${var.github_org}-runners"
}

resource helm_release github_runners {
  name      = var.release_name
  chart     = "${path.module}/github-actions-runners"
  namespace = var.namespace
  wait      = true

  values = [
    templatefile("${path.module}/runner-values.tpl", {
      github_org    = var.github_org
      runner_labels = yamlencode(length(var.runner_labels) > 0 ? {runner_labels: var.runner_labels} : {})
    })
  ]
}


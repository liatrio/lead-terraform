resource helm_release github_runner_controller {
  name       = var.release_name
  chart      = "./github-actions-runners"
  namespace  = var.namespace.name
  wait       = true

  values = [
    templatefile("${path.module}/runner-values.tpl", {
    })
  ]
}


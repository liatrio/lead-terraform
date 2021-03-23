data vault_generic_secret github_runner_app {
  for_each = var.github_runner_controllers

  path = "${var.cluster_name}/${var.platform_name}/${data.aws_caller_identity.current.account_id}/${each.value.vault_name}"
}

module github_runner_controller {
  for_each = var.github_runner_controllers

  source = "../../../modules/tools/github-actions-runner-controller"

  namespace = each.value.namespace

  github_app_id = data.vault_generic_secret.github_runner_app[each.key].data["github_app_id"]
  github_app_installation_id = data.vault_generic_secret.github_runner_app[each.key].data["github_app_installation_id"]
  github_app_private_key = data.vault_generic_secret.github_runner_app[each.key].data["github_app_private_key"]

  depends_on = [module.cert_manager]
}

module github_runners {
  for_each = var.github_runners

  source = "../../../modules/tools/github-actions-runners"
  github_org = each.value.github_org
  namespace = each.value.namespace
  runner_labels = each.value.runner_labels

  depends_on = [module.github_runner_controller]
}

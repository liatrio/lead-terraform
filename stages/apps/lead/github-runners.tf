data vault_generic_secret github_runner_app {
  count = var.enable_github_runners ? 1 : 0

  path = "${var.cluster_name}/${var.platform_name}/${data.aws_caller_identity.current.account_id}/github-runner-app-sandbox"
}

module github_runners {
  count = var.enable_github_runners ? 1 : 0

  source = "../../../modules/tools/github-actions-runners"

  github_app_id = data.vault_generic_secret.github_runner_app.0.data["github_app_id"]
  github_app_installation_id = data.vault_generic_secret.github_runner_app.0.data["github_app_installation_id"]
  github_app_private_key = data.vault_generic_secret.github_runner_app.0.data["github_app_private_key"]

  depends_on = [module.cert_manager]
}

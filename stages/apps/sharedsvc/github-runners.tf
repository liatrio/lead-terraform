data "vault_generic_secret" "github_runner_app" {
  for_each = var.github_runner_controllers

  path = "lead/aws/${data.aws_caller_identity.current.account_id}/${each.value.vault_name}"
}

module "github_runner_controller" {
  for_each = var.github_runner_controllers

  source = "../../../modules/tools/github-actions-runner-controller"

  namespace = each.value.namespace

  github_app_id               = data.vault_generic_secret.github_runner_app[each.key].data["github_app_id"]
  github_app_installation_id  = data.vault_generic_secret.github_runner_app[each.key].data["github_app_installation_id"]
  github_app_private_key      = data.vault_generic_secret.github_runner_app[each.key].data["github_app_private_key"]
  github_webhook_secret_token = data.vault_generic_secret.github_runner_app[each.key].data["github_webhook_secret_token"]
  github_webhook_annotations  = { "kubernetes.io/ingress.class" : "nginx-external" }

  github_org     = each.value.github_org
  ingress_domain = var.cluster_domain

  depends_on = [module.cert_manager]
}

module "github_runners" {
  for_each = var.github_runners

  source      = "../../../modules/tools/github-actions-runners"
  github_repo = each.value.github_repo
  github_org  = each.value.github_org
  namespace   = each.value.namespace
  image       = each.value.image
  labels      = each.value.labels

  github_runners_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = each.value.service_account_arn != "" ? each.value.service_account_arn : var.github_runners_service_account_arn
  }

  depends_on = [module.github_runner_controller]
}

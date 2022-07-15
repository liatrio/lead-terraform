data "vault_generic_secret" "github_runner_app" {
  for_each = var.github_runner_controllers

  path = "${var.cluster_name}/${var.platform_name}/${data.aws_caller_identity.current.account_id}/${each.value.vault_name}"
}

module "github_runner_controller" {
  for_each = var.github_runner_controllers

  source = "../../../modules/tools/github-actions-runner-controller"

  namespace = each.value.namespace

  github_app_id               = data.vault_generic_secret.github_runner_app[each.key].data["github_app_id"]
  github_app_installation_id  = data.vault_generic_secret.github_runner_app[each.key].data["github_app_installation_id"]
  github_app_private_key      = data.vault_generic_secret.github_runner_app[each.key].data["github_app_private_key"]
  github_webhook_secret_token = data.vault_generic_secret.github_runner_app[each.key].data["github_webhook_secret_token"]
  github_webhook_annotations  = { "kubernetes.io/ingress.class" : "toolchain-nginx" }

  github_org     = each.value.github_org
  ingress_domain = "toolchain.${var.cluster_name}.${var.root_zone_name}"

  depends_on = [module.cert_manager]
}

module "github_runners" {
  for_each = var.github_runners

  source      = "../../../modules/tools/github-actions-runners"
  github_org  = each.value.github_org
  github_repo = each.value.github_repo
  namespace   = each.value.namespace
  image       = each.value.image
  labels      = each.value.labels

  github_runners_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = var.github_runners_service_account_arn
  }

  depends_on = [module.github_runner_controller]
}

# Creating a Service Account and calling the service-account-role module to create a cluster-role and cluster-role-binding.
# This is created for the sharved-svc runners to have the correct permissions on the lead cluster.
resource "kubernetes_service_account" "github_runner_service_account" {
  metadata {
    name = var.github_runners_service_account_name
  }
}

module "github_service_account_rbac" {
  source = "../../../modules/common/service-account-rbac"

  service_account_name = kubernetes_service_account.github_runner_service_account.metadata.name
  cluster_role_name    = var.github_runners_cluster_role_name
  rules                = var.github_runners_cluster_role_rules
}

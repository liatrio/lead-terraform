module "mattermost" {
  count = var.enable_mattermost ? 1 : 0

  source = "../../../modules/tools/mattermost"

  mattermost_hostname   = "mattermost.${module.toolchain_namespace.name}.${var.cluster_name}.${var.root_zone_name}"
  namespace             = module.toolchain_namespace.name
  sparky_version        = var.sparky_mattermost_version
  toolchain_image_repo  = var.toolchain_image_repo
  mattermost_vault_path = "lead/aws/${data.aws_caller_identity.current.account_id}/mattermost"
  bot_email             = var.mattermost_bot_email
  bot_username          = var.mattermost_bot_username
}

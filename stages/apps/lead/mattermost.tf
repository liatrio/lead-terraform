module "mattermost" {
  count = var.enable_mattermost ? 1 : 0

  source = "../../../modules/tools/mattermost"

  mattermost_hostname = "mattermost.${module.toolchain_namespace.name}.${var.cluster_name}.${var.root_zone_name}"
  namespace           = module.toolchain_namespace.name
}

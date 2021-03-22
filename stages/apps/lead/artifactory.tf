data "vault_generic_secret" "artifactory" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/artifactory"
}

module "artifactory_jcr" {
  source = "../../../modules/tools/artifactory-jcr"

  count               = var.enable_artifactory ? 1 : 0
  namespace           = var.toolchain_namespace
  hostname            = "artifactory-jcr.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}"
  jcr_admin_password  = data.vault_generic_secret.artifactory.data["admin-password"]
}

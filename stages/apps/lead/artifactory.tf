data "vault_generic_secret" "artifactory_jcr" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/artifactory-jcr"
}

module "artifactory_jcr" {
  source = "../../../modules/tools/artifactory-jcr"

  count               = var.enable_artifactory_jcr ? 1 : 0
  namespace           = var.toolchain_namespace
  hostname            = "artifactory-jcr.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}"
  jcr_admin_password  = data.vault_generic_secret.artifactory_jcr.data["admin-password"]
}

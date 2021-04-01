data "vault_generic_secret" "artifactory_jcr" {
  count = var.enable_artifactory_jcr ? 1 : 0
  provider = vault.main
  path     = "lead/aws/${data.aws_caller_identity.current.account_id}/artifactory-jcr"
}

module "artifactory_jcr_config" {
  source = "../../../modules/config/artifactory-jcr"

  count = var.enable_artifactory_jcr ? 1 : 0
}

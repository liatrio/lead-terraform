data "vault_generic_secret" "artifactory" {
  provider = vault.main
  path     = "lead/aws/${data.aws_caller_identity.current.account_id}/artifactory"
}

module "artifactory_config" {
  source = "../../../modules/config/artifactory-jcr"

  count = var.enable_artifactory_jcr ? 1 : 0
}

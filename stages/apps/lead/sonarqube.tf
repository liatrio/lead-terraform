data "vault_generic_secret" "sonarqube" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/sonarqube"
}

module "sonarqube" {
  source = "../../../modules/tools/sonarqube"

  enable_sonarqube            = var.enable_sonarqube
  admin_password              = data.vault_generic_secret.sonarqube.data["admin_password"]
  namespace                   = var.toolchain_namespace
}


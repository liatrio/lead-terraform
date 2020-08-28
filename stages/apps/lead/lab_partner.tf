data "vault_generic_secret" "lab_partner" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/lab-partner"
}

module "lab_partner" {
  source                      = "../../modules/tools/lab-partner"
  enable_lab_partner          = var.enable_lab_partner
  root_zone_name              = var.root_zone_name
  cluster                     = var.cluster
  namespace                   = var.toolchain_namespace
  slack_bot_token             = data.vault_generic_secret.lab_partner.data["slack-bot-user-oauth-access-token"]
  slack_client_signing_secret = data.vault_generic_secret.lab_partner.data["slack-signing-secret"]
  team_id                     = data.vault_generic_secret.lab_partner.data["slack-team-id"]
  lab_partner_version         = var.lab_partner_version
  mongodb_password            = data.vault_generic_secret.lab_partner.data["mongodb-password"]
}

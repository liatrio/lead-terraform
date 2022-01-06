data "aws_caller_identity" "current" {}

data "vault_generic_secret" "lab_partner" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/lab-partner"
}

resource "helm_release" "lab_partner" {
  repository = "https://liatrio-helm.s3.us-east-1.amazonaws.com/charts"
  timeout    = 120
  name       = "lab-partner"
  chart      = "lab-partner"
  version    = var.lab_partner_version
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/lab-partner-values.tpl", {
      namespace      = var.namespace
      cluster_domain = "${var.cluster}.${var.root_zone_name}"

      slack_bot_token             = data.vault_generic_secret.lab_partner.data["slack-bot-user-oauth-access-token"]
      slack_client_signing_secret = data.vault_generic_secret.lab_partner.data["slack-signing-secret"]
      team_id                     = data.vault_generic_secret.lab_partner.data["slack-team-id"]
      mongodb_password            = data.vault_generic_secret.lab_partner.data["mongodb-password"]
    })
  ]
}

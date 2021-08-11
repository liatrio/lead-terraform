data "vault_generic_secret" "keycloak" {
  path     = "lead/aws/${data.aws_caller_identity.current.account_id}/keycloak"
}

data "vault_generic_secret" "sonarqube" {
  path     = "lead/aws/${data.aws_caller_identity.current.account_id}/sonarqube"
}

locals {
  realm = "liatrio"
}

resource "keycloak_realm" "sharedsvc" {
#  depends_on   = [
#    null_resource.keycloak_realm_delay
#  ]

  realm        = local.realm
  enabled      = true
  display_name = title(local.realm)

  registration_allowed           = false
  registration_email_as_username = false
  reset_password_allowed         = true
  remember_me                    = true
  verify_email                   = true
  login_with_email_allowed       = true
  duplicate_emails_allowed       = false
}

resource "keycloak_oidc_google_identity_provider" "sharedsvc" {
  realm         = keycloak_realm.sharedsvc.id
  client_id     = data.vault_generic_secret.keycloak.data["google_client_id"]
  client_secret = data.vault_generic_secret.keycloak.data["google_client_secret"]
  trust_email   = true
  hosted_domain = "liatrio.com"
}

resource "keycloak_openid_client" "sonarqube" {
  realm_id            = keycloak_realm.sharedsvc.id
  client_id           = var.sonar_keycloak_client_id

  name                = "sonarqube"
  enabled             = true

  client_secret = data.vault_generic_secret.sonarqube.data["keycloak_client_secret"]

  standard_flow_enabled = true

  access_type         = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://${var.sonarqube_hostname}/oauth2/callback/oidc"
  ]

  login_theme = "keycloak"
}

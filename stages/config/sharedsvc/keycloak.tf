data "vault_generic_secret" "keycloak" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/keycloak"
}

data "vault_generic_secret" "sonarqube" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/sonarqube"
}

data "vault_generic_secret" "rode" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/rode"
}

locals {
  realm = "liatrio"
}

resource "keycloak_realm" "sharedsvc" {
  realm        = local.realm
  enabled      = true
  display_name = title(local.realm)

  registration_allowed           = false
  registration_email_as_username = false
  remember_me                    = true
  verify_email                   = true
  login_with_email_allowed       = true
  duplicate_emails_allowed       = false
}

resource "keycloak_oidc_google_identity_provider" "sharedsvc" {
  realm         = keycloak_realm.sharedsvc.id
  client_id     = data.vault_generic_secret.keycloak.data["google-idp-client-id"]
  client_secret = data.vault_generic_secret.keycloak.data["google-idp-client-secret"]
  trust_email   = true
  hosted_domain = "liatrio.com"
}

resource "keycloak_openid_client" "sonarqube" {
  realm_id  = keycloak_realm.sharedsvc.id
  client_id = var.sonar_keycloak_client_id

  name    = "sonarqube"
  enabled = true

  client_secret = data.vault_generic_secret.sonarqube.data["keycloak_client_secret"]

  standard_flow_enabled = true

  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://${var.sonarqube_hostname}/oauth2/callback/oidc"
  ]
}

resource "keycloak_saml_client" "github_enterprise_cloud" {
  realm_id  = keycloak_realm.sharedsvc.id
  client_id = "https://github.com/orgs/liatrio-cloud"

  name    = "github enterprise cloud"
  enabled = true

  include_authn_statement   = true
  sign_documents            = true
  sign_assertions           = true
  client_signature_required = false

  signature_algorithm = "RSA_SHA256"
  signature_key_name  = "KEY_ID"

  force_post_binding   = true
  front_channel_logout = true

  name_id_format = "username"

  valid_redirect_uris = [
    "https://github.com/orgs/liatrio-cloud/*"
  ]
  master_saml_processing_url = "https://github.com/orgs/liatrio-cloud/saml/consume"
}

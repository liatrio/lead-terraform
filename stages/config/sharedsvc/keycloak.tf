data "vault_generic_secret" "keycloak" {
  provider = vault.main
  path     = "lead/aws/${data.aws_caller_identity.current.account_id}/keycloak"
}

data "vault_generic_secret" "sonarqube" {
  provider = vault.main
  path     = "lead/aws/${data.aws_caller_identity.current.account_id}/sonarqube"
}

module "keycloak_config" {
  source = "../../../modules/config/keycloak"

  enable_keycloak                        = true
  namespace                              = var.keycloak_namespace
  enable_google_login                    = true
  google_identity_provider_client_id     = data.vault_generic_secret.keycloak.data["google-idp-client-id"]
  google_identity_provider_client_secret = data.vault_generic_secret.keycloak.data["google-idp-client-secret"]
  enable_test_user                       = true
  test_user_password                     = data.vault_generic_secret.keycloak.data["test-user-password"]
}


resource "keycloak_openid_client" "openid_client" {
  realm_id            = module.keycloak_config.keycloak_realm_id
  client_id           = var.sonar_keycloak_client_id

  name                = "sonarqube"
  enabled             = true

  client_secret = data.vault_generic_secret.keycloak.data["INSERT_VAULT_KEY_HERE"]

  standard_flow_enabled = true

  access_type         = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://${var.sonarqube_hostname}/oauth2/callback/oidc"
  ]

  login_theme = "keycloak"
}

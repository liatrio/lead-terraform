data "vault_generic_secret" "keycloak" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/keycloak"
}

module "keycloak_config" {
  source = "../../../modules/config/keycloak"

  enable_keycloak                        = var.enable_keycloak
  namespace                              = var.toolchain_namespace
  enable_google_login                    = var.enable_google_login
  google_identity_provider_client_id     = var.enable_google_login ? data.vault_generic_secret.keycloak.data["google-idp-client-id"] : ""
  google_identity_provider_client_secret = var.enable_google_login ? data.vault_generic_secret.keycloak.data["google-idp-client-secret"] : ""
  enable_test_user                       = var.enable_test_user
  test_user_password                     = var.enable_test_user ? data.vault_generic_secret.keycloak.data["test-user-password"] : ""
}

 data "vault_generic_secret" "harbor" {
   path     = "lead/aws/${data.aws_caller_identity.current.account_id}/harbor"
 }

module "harbor_config" {
  source = "../../../modules/config/harbor"

  namespace         = var.harbor_namespace
  hostname          = var.harbor_hostname
  admin_password    = data.vault_generic_secret.harbor.data["admin-password"]
  enable_keycloak   = true
  keycloak_hostname = var.keycloak_hostname
  keycloak_realm    = keycloak_realm.sharedsvc.id
}

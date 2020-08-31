module "kibana_config" {
  source = "../../../modules/config/kibana"

  enable_keycloak   = var.enable_keycloak
  namespace         = var.toolchain_namespace
  keycloak_realm    = module.keycloak_config.keycloak_realm_id
  kibana_hostname   = var.kibana_hostname
  keycloak_hostname = var.keycloak_hostname
}

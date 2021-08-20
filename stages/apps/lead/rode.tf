module "rode" {
  source = "../../../modules/tools/rode"

  count = var.enable_rode ? 1 : 0

  namespace                = var.toolchain_namespace
  rode_ingress_hostname          = "rode.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}"

  grafeas_elasticsearch_password = data.vault_generic_secret.keycloak.data["FIX_ME"]
  grafeas_elasticsearch_username = data.vault_generic_secret.keycloak.data["FIX_ME"]
}

module "elasticsearch_namespace" {
  source = "../../modules/common/namespace"

  namespace   = "elasticsearch"
  annotations = {
    name    = "elasticsearch"
    cluster = module.eks.cluster_id
  }
}

module "elasticsearch" {
  source = "../../modules/tools/elasticsearch"

  cert_manager_crd_waiter = module.cert_manager.crd_waiter
  namespace               = module.elasticsearch_namespace.name
  root_zone_name          = var.root_zone_name
  disk_size               = "50Gi"
}

module "kibana" {
  source = "../../modules/tools/kibana"

  namespace                              = module.elasticsearch_namespace.name
  elasticsearch_credentials_secret_name  = module.elasticsearch.elasticsearch_credentials_secret_name
  elasticsearch_certificates_secret_name = module.elasticsearch.elasticsearch_certificates_secret_name

  // keycloak configuration for gatekeeper
  enable_keycloak                  = var.enable_keycloak
  keycloak_hostname                = module.keycloak.keycloak_hostname
  keycloak_admin_credential_secret = module.keycloak_config.keycloak_admin_credential_secret
  toolchain_namespace              = module.toolchain.namespace
  keycloak_realm                   = module.keycloak_config.keycloak_realm_id
  kibana_hostname                  = "kibana.${module.toolchain.namespace}.${var.cluster}.${var.root_zone_name}"
}

module "fluent_bit" {
  source = "../../modules/tools/fluent-bit"

  namespace                              = module.elasticsearch_namespace.name
  elasticsearch_credentials_secret_name  = module.elasticsearch.elasticsearch_credentials_secret_name
  elasticsearch_username                 = module.elasticsearch.elasticsearch_username
}

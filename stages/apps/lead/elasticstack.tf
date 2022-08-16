module "elasticsearch_namespace" {
  source = "../../../modules/common/namespace"

  namespace = "elasticsearch"
  annotations = {
    name    = "elasticsearch"
    cluster = var.cluster_name
  }
}

module "elasticsearch" {
  source = "../../../modules/tools/elasticsearch"

  namespace      = module.elasticsearch_namespace.name
  root_zone_name = var.root_zone_name
  disk_size      = "50Gi"

  depends_on = [
    module.cert_manager
  ]
}

module "kibana" {
  source = "../../../modules/tools/kibana"

  namespace                              = module.elasticsearch_namespace.name
  elasticsearch_credentials_secret_name  = module.elasticsearch.elasticsearch_credentials_secret_name
  elasticsearch_certificates_secret_name = module.elasticsearch.elasticsearch_certificates_secret_name

  // ingress should only be enabled if keycloak is disabled (if keycloak is enabled, we use gatekeeper) and if the feature flag is set to `true`
  enable_ingress  = !var.enable_keycloak && var.enable_kibana_ingress
  kibana_hostname = "kibana.${module.toolchain_namespace.name}.${var.cluster_name}.${var.root_zone_name}"
}

module "fluent_bit" {
  source = "../../../modules/tools/fluent-bit"

  namespace                             = module.elasticsearch_namespace.name
  elasticsearch_credentials_secret_name = module.elasticsearch.elasticsearch_credentials_secret_name
  elasticsearch_username                = module.elasticsearch.elasticsearch_username
}

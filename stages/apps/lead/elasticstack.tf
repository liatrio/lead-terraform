module "elasticsearch_namespace" {
  source = "../../../modules/common/namespace"

  namespace   = "elasticsearch"
  annotations = {
    name    = "elasticsearch"
    cluster = var.cluster_name
  }
}

module "elasticsearch" {
  source = "../../../modules/tools/elasticsearch"

  cert_manager_crd_waiter = module.cert_manager.crd_waiter
  namespace               = module.elasticsearch_namespace.name
  root_zone_name          = var.root_zone_name
  disk_size               = "50Gi"
}

module "kibana" {
  source = "../../../modules/tools/kibana"

  namespace                              = module.elasticsearch_namespace.name
  elasticsearch_credentials_secret_name  = module.elasticsearch.elasticsearch_credentials_secret_name
  elasticsearch_certificates_secret_name = module.elasticsearch.elasticsearch_certificates_secret_name

  // keycloak configuration for gatekeeper
  enable_keycloak                  = var.enable_keycloak
}

module "fluent_bit" {
  source = "../../../modules/tools/fluent-bit"

  namespace                              = module.elasticsearch_namespace.name
  elasticsearch_credentials_secret_name  = module.elasticsearch.elasticsearch_credentials_secret_name
  elasticsearch_username                 = module.elasticsearch.elasticsearch_username
}

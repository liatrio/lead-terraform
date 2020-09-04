module "elasticsearch_namespace" {
  source = "../../../modules/common/namespace"

  count       = var.enable_elasticstack ? 1 : 0
  namespace   = "elasticsearch"
  annotations = {
    name    = "elasticsearch"
    cluster = var.cluster_name
  }
}

module "elasticsearch" {
  source = "../../../modules/tools/elasticsearch"

  count                   = var.enable_elasticstack ? 1 : 0
  namespace               = var.enable_elasticstack ? module.elasticsearch_namespace.name : null
  root_zone_name          = var.root_zone_name
  disk_size               = "50Gi"

  depends_on = [
    module.cert_manager
  ]
}

module "kibana" {
  source = "../../../modules/tools/kibana"

  count                                  = var.enable_elasticstack ? 1 : 0
  namespace                              = var.enable_elasticstack ? module.elasticsearch_namespace.name : null
  elasticsearch_credentials_secret_name  = var.enable_elasticstack ? module.elasticsearch.elasticsearch_credentials_secret_name : null
  elasticsearch_certificates_secret_name = var.enable_elasticstack ? module.elasticsearch.elasticsearch_certificates_secret_name : null
}

module "fluent_bit" {
  source = "../../../modules/tools/fluent-bit"

  count                                  = var.enable_elasticstack ? 1 : 0
  namespace                              = var.enable_elasticstack ? module.elasticsearch_namespace.name : null
  elasticsearch_credentials_secret_name  = var.enable_elasticstack ? module.elasticsearch.elasticsearch_credentials_secret_name : null
  elasticsearch_username                 = var.enable_elasticstack ? module.elasticsearch.elasticsearch_username : null
}

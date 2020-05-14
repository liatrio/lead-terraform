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
  disk_size               = "30Gi"
}

module "kibana" {
  source = "../../modules/tools/kibana"

  namespace                              = module.elasticsearch_namespace.name
  elasticsearch_credentials_secret_name  = module.elasticsearch.elasticsearch_credentials_secret_name
  elasticsearch_certificates_secret_name = module.elasticsearch.elasticsearch_certificates_secret_name
}

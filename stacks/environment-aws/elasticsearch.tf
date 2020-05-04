module "elasticsearch_namespace" {
  source = "../../modules/common/namespace"

  namespace = "elasticsearch"
  annotations = {
    name = "elasticsearch"
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

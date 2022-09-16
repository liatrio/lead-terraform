module "elasticsearch_namespace" {
  source = "../../../modules/common/namespace"

  namespace = "elasticsearch"
  annotations = {
    name    = "elasticsearch"
    cluster = var.eks_cluster_id
  }
}

module "elasticsearch" {
  source = "../../../modules/tools/elasticsearch"

  namespace      = module.elasticsearch_namespace.name
  root_zone_name = var.cluster_domain
  disk_size      = "50Gi"

  depends_on = [
    module.cert_manager
  ]
}

### We are not currently deploying kibana or fluent bit into shared service
### Leaving these modules here in case we want to enable them in the future
#
# module "kibana" {
#   source = "../../../modules/tools/kibana"

#   namespace                              = module.elasticsearch_namespace.name
#   elasticsearch_credentials_secret_name  = module.elasticsearch.elasticsearch_credentials_secret_name
#   elasticsearch_certificates_secret_name = module.elasticsearch.elasticsearch_certificates_secret_name

#   enable_ingress  = true
#   kibana_hostname = "kibana.${var.eks_cluster_id}.${var.cluster_domain}"
# }

# module "fluent_bit" {
#   source = "../../../modules/tools/fluent-bit"

#   namespace                             = module.elasticsearch_namespace.name
#   elasticsearch_credentials_secret_name = module.elasticsearch.elasticsearch_credentials_secret_name
#   elasticsearch_username                = module.elasticsearch.elasticsearch_username
# }

locals {
  docker_registry_hostname = "docker-registry.${var.internal_cluster_domain}"
}

module "docker_registry_namespace" {
  source      = "../../../modules/common/namespace"
  namespace   = "docker-registry"
  annotations = {
    name    = "docker-registry"
    cluster = var.eks_cluster_id
  }
}

module "docker_registry" {
  source = "../../../modules/tools/docker-registry"

  docker_registry_aws_access_key_id     = var.docker_registry_aws_access_key_id
  docker_registry_aws_secret_access_key = var.docker_registry_aws_secret_access_key
  docker_registry_s3_bucket_name        = var.docker_registry_s3_bucket_name
  hostname                              = local.docker_registry_hostname
  namespace                             = module.docker_registry_namespace.name
  region                                = var.region
}

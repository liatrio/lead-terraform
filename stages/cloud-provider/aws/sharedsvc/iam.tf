module "cluster_autoscaler_iam" {
  source = "../../../../modules/environment/aws/iam/cluster-autoscaler"

  cluster                     = module.eks.cluster_id
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
}

data "aws_route53_zone" "private_internal_services_liatr_io" {
  name         = "${var.internal_cluster_domain}."
  private_zone = true
}

data "aws_route53_zone" "public_internal_services_liatr_io" {
  name = "${var.internal_cluster_domain}."
}

data "aws_route53_zone" "services_liatr_io" {
  name = "${var.cluster_domain}."
}

module "external_dns_iam" {
  source = "../../../../modules/environment/aws/iam/external-dns"

  cluster                     = module.eks.cluster_id
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
  route53_zone_ids            = [
    data.aws_route53_zone.private_internal_services_liatr_io.zone_id,
    data.aws_route53_zone.services_liatr_io.zone_id
  ]
}

module "cert_manager_iam" {
  source = "../../../../modules/environment/aws/iam/cert-manager"

  cluster                     = module.eks.cluster_id
  namespace                   = var.system_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
}

module "docker_registry_iam" {
  source = "../../../../modules/environment/aws/iam/docker-registry"

  cluster = module.eks.cluster_id
}

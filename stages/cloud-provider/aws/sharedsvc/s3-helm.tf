locals {
  helm_repository_url = "charts.services.liatr.io"
}

module "helm_s3_website" {
  source = "../../../../modules/environment/aws/s3-website"

  domain                      = local.helm_repository_url
  route53_zone_id             = data.aws_route53_zone.services_liatr_io.zone_id
  create_deployer_credentials = true
}

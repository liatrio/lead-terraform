variable "cluster" {
  type = string
}

variable "namespace" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "kubeconfig_path" {
  type = string
}

module "iam" {
  source = "../../../../../environment/aws/iam/cert-manager"

  namespace                   = var.namespace
  cluster                     = var.cluster
  hosted_zone_id              = data.aws_route53_zone.zone.zone_id
  openid_connect_provider_arn = var.oidc_provider_arn
  openid_connect_provider_url = var.oidc_provider_url
}

module "cert_manager" {
  source = "../../../"

  namespace                             = var.namespace
  cert_manager_service_account_role_arn = module.iam.cert_manager_service_account_arn
}

data "aws_route53_zone" "zone" {
  name = var.hosted_zone_name
}

module "issuer" {
  source = "../../../../../common/cert-issuer"

  namespace = var.namespace

  issuer_name   = "staging-letsencrypt-dns"
  issuer_kind   = "Issuer"
  issuer_type   = "acme"
  issuer_server = "https://acme-staging-v02.api.letsencrypt.org/directory"

  acme_solver       = "dns"
  provider_dns_type = "route53"

  route53_dns_region      = "us-east-1"
  route53_dns_hosted_zone = data.aws_route53_zone.zone.zone_id

  depends_on = [
    module.cert_manager,
  ]
}

module "certificate" {
  source = "../../../../../common/certificates"

  domain        = "${var.namespace}.${var.hosted_zone_name}"
  name          = var.namespace
  namespace     = var.namespace
  issuer_name   = module.issuer.issuer_name
  issuer_kind   = module.issuer.issuer_kind
  wait_for_cert = true

  depends_on = [
    module.cert_manager,
  ]
}

output "certificate_secret_name" {
  value = module.certificate.cert_secret_name
}

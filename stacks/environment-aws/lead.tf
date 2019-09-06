data "template_file" "external_dns_values" {
  template = file("${path.module}/external-dns-values.tpl")

  vars = {
    domain_filter = "${module.eks.cluster_id}.${var.root_zone_name}"
  }
}

module "infrastructure" {
  source             = "../../modules/lead/infrastructure"
  cluster            = module.eks.cluster_id
  namespace          = var.system_namespace
  opa_failure_policy = var.opa_failure_policy
  enable_opa         = "false"
  issuer_type        = "acme"
  issuer_server      = var.cert_issuer_server
  uptime             = var.uptime

  enable_spot_instances      = var.enable_spot_instances
  ondemand_toleration_values = data.template_file.ondemand_toleration.rendered
  external_dns_chart_values  = data.template_file.external_dns_values.rendered

  providers = {
    helm = helm.system
  }
}

data "template_file" "cluster_autoscaler" {
  template = file("${path.module}/cluster-autoscaler-values.tpl")

  vars = {
    cluster = var.cluster
    region  = var.region
    scale_down_enabled = var.enable_autoscaler_scale_down
  }
}

data "template_file" "ondemand_toleration" {
  template = file("${path.module}/ondemand-toleration.tpl")
  vars = {
    ondemand_toleration_key = var.ondemand_toleration_key
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = module.infrastructure.namespace
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "cluster-autoscaler"
  timeout    = 600
  wait       = true
  version    = "3.1.0"

  values = [data.template_file.cluster_autoscaler.rendered, data.template_file.ondemand_toleration.rendered]

  provider = helm.system
}

module "ses_smtp" {
  source       = "../../modules/common/aws-ses-smtp"
  name         = "ses-smtp-${module.toolchain.namespace}"
  from_address = var.from_email
}

module "toolchain" {
  source                  = "../../modules/lead/toolchain"
  root_zone_name          = var.root_zone_name
  cluster                 = module.eks.cluster_id
  namespace               = var.toolchain_namespace
  image_whitelist         = var.image_whitelist
  elb_security_group_id   = aws_security_group.elb.id
  artifactory_license     = var.artifactory_license
  keycloak_admin_password = var.keycloak_admin_password
  enable_artifactory      = var.enable_artifactory
  enable_gitlab           = var.enable_gitlab
  enable_keycloak         = var.enable_keycloak
  enable_mailhog          = var.enable_mailhog
  enable_sonarqube        = var.enable_sonarqube
  enable_xray             = var.enable_xray
  issuer_type             = "acme"
  issuer_server           = var.cert_issuer_server
  ingress_controller_type = "LoadBalancer"
  crd_waiter              = module.infrastructure.crd_waiter

  smtp_json = {
    aws_ses = {
      name     = "aws_ses"
      host     = "email-smtp.${var.region}.amazonaws.com"
      port     = "587"
      email    = var.from_email
      username = module.ses_smtp.smtp_username
      password = module.ses_smtp.smtp_password
    }
  }

  providers = {
    helm = helm.toolchain
  }
}

module "sdm" {
  source                      = "../../modules/lead/sdm"
  root_zone_name              = var.root_zone_name
  cluster                     = module.eks.cluster_id
  namespace                   = module.toolchain.namespace
  system_namespace            = module.infrastructure.namespace
  sdm_version                 = var.sdm_version
  product_version             = var.product_version
  slack_bot_token             = var.slack_bot_token
  slack_client_signing_secret = var.slack_client_signing_secret
  workspace_role_name         = aws_iam_role.workspace_role.name
  cert_issuer_type            = var.cert_issuer_type
  cert_issuer_server          = var.cert_issuer_server
  product_stack               = "product-aws"

  providers = {
    helm.system    = helm.system
    helm.toolchain = helm.toolchain
  }
}

module "dashboard" {
  source            = "../../modules/lead/dashboard"
  root_zone_name    = var.root_zone_name
  cluster           = module.eks.cluster_id
  namespace         = module.toolchain.namespace
  dashboard_version = var.dashboard_version

  providers = {
    helm = helm.toolchain
  }
}

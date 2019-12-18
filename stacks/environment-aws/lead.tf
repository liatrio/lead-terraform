data "template_file" "external_dns_values" {
  template = file("${path.module}/external-dns-values.tpl")

  vars = {
    domain_filter = "${module.eks.cluster_id}.${var.root_zone_name}"
  }
}

module "infrastructure" {
  source                                = "../../modules/lead/infrastructure"
  cluster                               = module.eks.cluster_id
  namespace                             = var.system_namespace
  opa_failure_policy                    = var.opa_failure_policy
  enable_opa                            = "false"
  issuer_type                           = "acme"
  issuer_server                         = var.cert_issuer_server
  uptime                                = var.uptime
  downscaler_exclude_namespaces         = var.downscaler_exclude_namespaces
  cert_manager_service_account_role_arn = aws_iam_role.cert_manager_service_account.arn
  essential_toleration_values           = data.template_file.essential_toleration.rendered
  external_dns_chart_values             = data.template_file.external_dns_values.rendered
  external_dns_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns_service_account.arn
  }
  providers = {
    helm       = helm.system
    kubernetes = kubernetes
  }
}


data "template_file" "cluster_autoscaler" {
  template = file("${path.module}/cluster-autoscaler-values.tpl")

  vars = {
    cluster            = var.cluster
    region             = var.region
    scale_down_enabled = var.enable_autoscaler_scale_down
    iam_arn            = aws_iam_role.cluster_autoscaler_service_account.arn
  }
}

data "template_file" "essential_toleration" {
  template = file("${path.module}/essential-toleration.tpl")
  vars = {
    essential_taint_key = var.essential_taint_key
  }
}

data "helm_repository" "stable" {
  name     = "stable"
  url      = "https://kubernetes-charts.storage.googleapis.com"
  provider = helm.system
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = module.infrastructure.namespace
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "cluster-autoscaler"
  timeout    = 600
  wait       = true
  version    = "6.0.1"

  values = [data.template_file.cluster_autoscaler.rendered, data.template_file.essential_toleration.rendered]

  provider = helm.system
}


data "aws_ssm_parameter" "slack_client_signing_secret" {
  name = "/${var.cluster}/slack_client_signing_secret"
}

data "aws_ssm_parameter" "slack_bot_token" {
  name = "/${var.cluster}/slack_bot_token"
}

data "aws_ssm_parameter" "artifactory_license" {
  name = "/${var.cluster}/artifactory_license"
}

data "aws_ssm_parameter" "keycloak_admin_password" {
  name = "/${var.cluster}/keycloak_admin_password"
}

data "aws_ssm_parameter" "prometheus_slack_webhook_url" {
  name = "/${var.cluster}/prometheus_slack_webhook_url"
}


module "toolchain" {
  source                  = "../../modules/lead/toolchain"
  root_zone_name          = var.root_zone_name
  cluster                 = module.eks.cluster_id
  cluster_domain          = "${var.cluster}.${var.root_zone_name}"
  namespace               = var.toolchain_namespace
  image_whitelist         = var.image_whitelist
  elb_security_group_id   = aws_security_group.elb.id
  artifactory_license     = data.aws_ssm_parameter.artifactory_license.value
  keycloak_admin_password = data.aws_ssm_parameter.keycloak_admin_password.value
  enable_istio            = var.enable_istio
  enable_artifactory      = var.enable_artifactory
  enable_gitlab           = var.enable_gitlab
  enable_keycloak         = var.enable_keycloak
  enable_mailhog          = var.enable_mailhog
  enable_sonarqube        = var.enable_sonarqube
  enable_xray             = var.enable_xray
  enable_grafeas          = var.enable_grafeas
  enable_harbor           = var.enable_harbor
  issuer_type             = "acme"
  issuer_server           = var.cert_issuer_server
  ingress_controller_type = "LoadBalancer"
  crd_waiter              = module.infrastructure.crd_waiter
  grafeas_version         = var.grafeas_version

  harbor_registry_disk_size = "200Gi"
  harbor_chartmuseum_disk_size = "100Gi"

  prometheus_slack_webhook_url    = data.aws_ssm_parameter.prometheus_slack_webhook_url.value
  prometheus_slack_channel        = var.prometheus_slack_channel

  smtp_host       = "email-smtp.${var.region}.amazonaws.com"
  smtp_port       = "587"
  smtp_username   = module.ses_smtp.smtp_username
  smtp_password   = module.ses_smtp.smtp_password
  smtp_from_email = "noreply@${aws_ses_domain_identity.cluster_domain.domain}"

  providers = {
    helm        = helm.toolchain
    helm.system = helm.system
    kubernetes  = kubernetes
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
  slack_bot_token             = data.aws_ssm_parameter.slack_bot_token.value
  slack_client_signing_secret = data.aws_ssm_parameter.slack_client_signing_secret.value
  workspace_role_name         = aws_iam_role.workspace_role.name
  product_stack               = "product-aws"
  nginx_ingress_waiter        = module.toolchain.nginx_ingress_waiter

  operator_slack_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.operator_slack_service_account.arn
  }
  operator_jenkins_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.operator_jenkins_service_account.arn
  }

  product_vars = {
    issuer_type            = var.cert_issuer_type
    issuer_server          = var.cert_issuer_server
    enable_keycloak        = var.enable_keycloak
    builder_images_version = var.builder_images_version
    jenkins_image_version  = var.jenkins_image_version
    image_repo             = var.image_repo
  }

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
  enabled           = var.enable_dashboard

  providers = {
    helm = helm.toolchain
  }
}

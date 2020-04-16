data "template_file" "external_dns_values" {
  template = file("${path.module}/external-dns-values.tpl")

  vars = {
    domain_filter = "${module.eks.cluster_id}.${var.root_zone_name}"
  }
}

module "infrastructure" {
  source                                   = "../../modules/lead/infrastructure"
  cluster                                  = module.eks.cluster_id
  namespace                                = var.system_namespace
  opa_failure_policy                       = var.opa_failure_policy
  enable_opa                               = "false"
  enable_downscaler                        = true
  enable_k8s_spot_termination_handler      = true
  uptime                                   = var.uptime
  downscaler_exclude_namespaces            = var.downscaler_exclude_namespaces
  cert_manager_service_account_role_arn    = aws_iam_role.cert_manager_service_account.arn
  essential_toleration_values              = data.template_file.essential_toleration.rendered
  external_dns_chart_values                = data.template_file.external_dns_values.rendered
  external_dns_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns_service_account.arn
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
  vars     = {
    essential_taint_key = var.essential_taint_key
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
  version    = "6.6.1"

  values = [
    data.template_file.cluster_autoscaler.rendered,
    data.template_file.essential_toleration.rendered
  ]
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

data "aws_ssm_parameter" "keycloak_postgres_password" {
  name = "/${var.cluster}/keycloak_postgres_password"
}

data "aws_ssm_parameter" "prometheus_slack_webhook_url" {
  name = "/${var.cluster}/prometheus_slack_webhook_url"
}


module "toolchain" {
  source                     = "../../modules/lead/toolchain"
  root_zone_name             = var.root_zone_name
  cluster                    = module.eks.cluster_id
  namespace                  = var.toolchain_namespace
  image_whitelist            = var.image_whitelist
  elb_security_group_id      = module.eks.aws_security_group_elb.id
  artifactory_license        = data.aws_ssm_parameter.artifactory_license.value
  keycloak_admin_password    = data.aws_ssm_parameter.keycloak_admin_password.value
  keycloak_postgres_password = data.aws_ssm_parameter.keycloak_postgres_password.value
  enable_istio               = var.enable_istio
  enable_artifactory         = var.enable_artifactory
  enable_gitlab              = var.enable_gitlab
  enable_keycloak            = var.enable_keycloak
  enable_mailhog             = var.enable_mailhog
  enable_sonarqube           = var.enable_sonarqube
  enable_xray                = var.enable_xray
  enable_grafeas             = var.enable_grafeas
  enable_harbor              = var.enable_harbor
  issuer_name                = module.cluster_issuer.issuer_name
  issuer_kind                = module.cluster_issuer.issuer_kind
  crd_waiter                 = module.infrastructure.crd_waiter
  grafeas_version            = var.grafeas_version
  k8s_storage_class          = var.k8s_storage_class

  harbor_registry_disk_size    = "200Gi"
  harbor_chartmuseum_disk_size = "100Gi"

  prometheus_slack_webhook_url = data.aws_ssm_parameter.prometheus_slack_webhook_url.value
  prometheus_slack_channel     = var.prometheus_slack_channel

  smtp_host       = "email-smtp.${var.region}.amazonaws.com"
  smtp_port       = "587"
  smtp_username   = module.ses_smtp.smtp_username
  smtp_password   = module.ses_smtp.smtp_password
  smtp_from_email = "noreply@${aws_ses_domain_identity.cluster_domain.domain}"
}

module "toolchain_ingress" {
  source                  = "../../modules/lead/toolchain-ingress"
  namespace               = var.toolchain_namespace
  cluster_domain          = "${var.cluster}.${var.root_zone_name}"
  issuer_name             = module.cluster_issuer.issuer_name
  issuer_kind             = module.cluster_issuer.issuer_kind
  ingress_controller_type = "LoadBalancer"
  crd_waiter              = module.infrastructure.crd_waiter
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
  workspace_role_name         = module.eks.workspace_iam_role.name
  operators                   = var.lead_sdm_operators
  product_types               = var.product_types
  enable_aws_event_mapper     = var.enable_aws_code_services
  remote_state_config         = file("./terragrunt-product-backend-s3.hcl")
  sqs_url                     = var.enable_aws_code_services ? module.codeservices.sqs_url : ""
  toolchain_image_repo        = var.toolchain_image_repo

  operator_slack_service_account_annotations   = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.operator_slack_service_account.arn
  }
  operator_jenkins_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.operator_jenkins_service_account.arn
  }
  operator_product_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.product_operator_service_account.arn
  }
  aws_event_mapper_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = module.codeservices.event_mapper_role_arn
  }

  product_vars = {
    enable_keycloak        = var.enable_keycloak
    builder_images_version = var.builder_images_version
    jenkins_image_version  = var.jenkins_image_version
    toolchain_image_repo   = var.toolchain_image_repo
    enable_harbor          = var.enable_harbor
    enable_artifactory     = var.enable_artifactory

    s3_bucket                   = var.enable_aws_code_services ? module.codeservices.s3_bucket : ""
    codebuild_role              = var.enable_aws_code_services ? module.codeservices.codebuild_role : ""
    codepipeline_role           = var.enable_aws_code_services ? module.codeservices.codepipeline_role : ""
    codebuild_user              = var.enable_aws_code_services ? "codebuild" : ""
    codebuild_security_group_id = module.codeservices.codebuild_security_group_id
    aws_environment             = var.aws_environment
    product_image_repo          = var.product_image_repo
  }
}

module "dashboard" {
  source                           = "../../modules/lead/dashboard"
  root_zone_name                   = var.root_zone_name
  cluster                          = module.eks.cluster_id
  cluster_domain                   = "${var.cluster}.${var.root_zone_name}"
  namespace                        = module.toolchain.namespace
  dashboard_version                = var.dashboard_version
  k8s_storage_class                = var.k8s_storage_class
  enabled                          = var.enable_dashboard
  enable_keycloak                  = var.enable_keycloak
  keycloak_realm_id                = module.toolchain.keycloak_realm_id
  crd_waiter                       = module.infrastructure.crd_waiter
  elasticsearch_replicas           = var.dashboard_elasticsearch_replicas
  toolchain_namespace              = module.toolchain.namespace
  keycloak_admin_credential_secret = module.toolchain.keycloak_admin_credential_secret
}

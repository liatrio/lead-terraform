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

data "aws_ssm_parameter" "google_identity_provider_client_id" {
  count = var.enable_google_login ? 1 : 0
  name  = "/${var.cluster}/google_identity_provider_client_id"
}

data "aws_ssm_parameter" "google_identity_provider_client_secret" {
  count = var.enable_google_login ? 1 : 0
  name  = "/${var.cluster}/google_identity_provider_client_secret"
}

data "aws_ssm_parameter" "test_user_password" {
  count = var.enable_test_user ? 1 : 0
  name  = "/${var.cluster}/test_user_password"
}


module "toolchain" {
  source                                 = "../../modules/lead/toolchain"
  root_zone_name                         = var.root_zone_name
  cluster                                = module.eks.cluster_id
  namespace                              = var.toolchain_namespace
  image_whitelist                        = var.image_whitelist
  elb_security_group_id                  = module.eks.aws_security_group_elb.id
  artifactory_license                    = data.aws_ssm_parameter.artifactory_license.value
  keycloak_admin_password                = data.aws_ssm_parameter.keycloak_admin_password.value
  keycloak_postgres_password             = data.aws_ssm_parameter.keycloak_postgres_password.value
  enable_google_login                    = var.enable_google_login
  google_identity_provider_client_id     = var.enable_google_login ? data.aws_ssm_parameter.google_identity_provider_client_id[0].value : ""
  google_identity_provider_client_secret = var.enable_google_login ? data.aws_ssm_parameter.google_identity_provider_client_secret[0].value : ""
  enable_test_user                       = var.enable_test_user
  test_user_password                     = var.enable_test_user ? data.aws_ssm_parameter.test_user_password[0].value : ""
  enable_istio                           = var.enable_istio
  enable_artifactory                     = var.enable_artifactory
  enable_gitlab                          = var.enable_gitlab
  enable_keycloak                        = var.enable_keycloak
  enable_mailhog                         = var.enable_mailhog
  enable_sonarqube                       = var.enable_sonarqube
  enable_xray                            = var.enable_xray
  enable_grafeas                         = var.enable_grafeas
  enable_harbor                          = var.enable_harbor
  issuer_name                            = module.cluster_issuer.issuer_name
  issuer_kind                            = module.cluster_issuer.issuer_kind
  crd_waiter                             = module.cert_manager.crd_waiter
  grafeas_version                        = var.grafeas_version
  k8s_storage_class                      = var.k8s_storage_class

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
  crd_waiter              = module.cert_manager.crd_waiter
}

module "sdm" {
  source                      = "../../modules/lead/sdm"
  root_zone_name              = var.root_zone_name
  cluster                     = module.eks.cluster_id
  namespace                   = module.toolchain.namespace
  system_namespace            = module.system_namespace.name
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

  harbor_image_repo = "harbor.${module.toolchain.namespace}.${module.eks.cluster_id}.${var.root_zone_name}"
  ecr_image_repo    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"

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
  }
}

module "dashboard" {
  source                           = "../../modules/lead/dashboard"
  enabled                          = var.enable_dashboard
  namespace                        = module.toolchain.namespace
  dashboard_version                = var.dashboard_version
}

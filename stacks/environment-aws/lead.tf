data "vault_generic_secret" "sparky" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/sparky"
}

data "vault_generic_secret" "artifactory" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/artifactory"
}

data "vault_generic_secret" "keycloak" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/keycloak"
}

data "vault_generic_secret" "prometheus" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/prometheus"
}

data "vault_generic_secret" "lab_partner" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/lab-partner"
}

module "toolchain" {
  source                                 = "../../modules/lead/toolchain"
  root_zone_name                         = var.root_zone_name
  cluster                                = module.eks.cluster_id
  namespace                              = var.toolchain_namespace
  image_whitelist                        = var.image_whitelist
  elb_security_group_id                  = module.eks.aws_security_group_elb.id
  artifactory_license                    = data.vault_generic_secret.artifactory.data["license"]
  keycloak_admin_password                = data.vault_generic_secret.keycloak.data["admin-password"]
  keycloak_postgres_password             = data.vault_generic_secret.keycloak.data["postgres-password"]
  enable_google_login                    = var.enable_google_login
  google_identity_provider_client_id     = var.enable_google_login ? data.vault_generic_secret.keycloak.data["google-idp-client-id"] : ""
  google_identity_provider_client_secret = var.enable_google_login ? data.vault_generic_secret.keycloak.data["google-idp-client-secret"] : ""
  enable_test_user                       = var.enable_test_user
  test_user_password                     = var.enable_test_user ? data.vault_generic_secret.keycloak.data["test-user-password"] : ""
  enable_istio                           = var.enable_istio
  enable_artifactory                     = var.enable_artifactory
  enable_gitlab                          = var.enable_gitlab
  enable_keycloak                        = var.enable_keycloak
  enable_mailhog                         = var.enable_mailhog
  enable_sonarqube                       = var.enable_sonarqube
  enable_harbor                          = var.enable_harbor
  enable_rode                            = var.enable_rode
  issuer_name                            = module.cluster_issuer.issuer_name
  issuer_kind                            = module.cluster_issuer.issuer_kind
  crd_waiter                             = module.cert_manager.crd_waiter
  k8s_storage_class                      = var.k8s_storage_class

  rode_service_account_arn               = aws_iam_role.rode_service_account.arn

  harbor_registry_disk_size    = "200Gi"
  harbor_chartmuseum_disk_size = "100Gi"

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
  slack_bot_token             = data.vault_generic_secret.sparky.data["slack-bot-user-oauth-access-token"]
  slack_client_signing_secret = data.vault_generic_secret.sparky.data["slack-signing-secret"]
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

module "lab_partner" {
  source                      = "../../modules/tools/lab-partner"
  enable_lab_partner          = var.enable_lab_partner
  root_zone_name              = var.root_zone_name
  cluster                     = module.eks.cluster_id
  namespace                   = var.toolchain_namespace
  slack_bot_token             = data.vault_generic_secret.lab_partner.data["slack-bot-user-oauth-access-token"]
  slack_client_signing_secret = data.vault_generic_secret.lab_partner.data["slack-signing-secret"]
  team_id                     = data.vault_generic_secret.lab_partner.data["slack-team-id"]
  lab_partner_version         = var.lab_partner_version
  mongodb_password            = data.vault_generic_secret.lab_partner.data["mongodb-password"]
}

module "vault" {
  source = "../../modules/tools/vault-less-secure"

  namespace                 = module.toolchain.namespace
  region                    = var.region
  vault_dynamodb_table_name = "vault.toolchain.${module.eks.cluster_id}.${var.root_zone_name}"
  vault_hostname            = "vault.toolchain.${module.eks.cluster_id}.${var.root_zone_name}"
}

module "prometheus-operator" {
  source = "../../modules/tools/prometheus"

  namespace                    = module.toolchain.namespace
  grafana_hostname             = "grafana.${module.toolchain.namespace}.${var.cluster}.${var.root_zone_name}"
  prometheus_slack_webhook_url = data.vault_generic_secret.prometheus.data["slack-webhook-url"]
  prometheus_slack_channel     = var.prometheus_slack_channel
}

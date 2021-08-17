data "vault_generic_secret" "sparky" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/sparky"
}

data "vault_generic_secret" "github_token" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/github"
} 

module "sdm" {
  source                      = "../../../modules/lead/sdm"
  root_zone_name              = var.root_zone_name
  cluster                     = var.cluster_name
  namespace                   = var.toolchain_namespace
  system_namespace            = var.system_namespace
  sdm_version                 = var.sdm_version
  product_version             = var.product_version
  slack_bot_token             = data.vault_generic_secret.sparky.data["slack-bot-user-oauth-access-token"]
  slack_client_signing_secret = data.vault_generic_secret.sparky.data["slack-signing-secret"]
  github_pat                  = data.vault_generic_secret.github_token.data["token"]
  github_pat_username         = data.vault_generic_secret.github_token.data["username"]
  registry                    = var.registry
  workspace_role_name         = var.workspace_role_name
  operators                   = var.lead_sdm_operators
  product_types               = var.product_types
  enable_aws_event_mapper     = var.enable_aws_code_services
  remote_state_config         = file("./terragrunt-product-backend-s3.hcl")
  sqs_url                     = var.enable_aws_code_services ? var.codeservices_sqs_url : ""
  toolchain_image_repo        = var.toolchain_image_repo


  artifactory_image_repo = var.enable_artifactory_jcr ? "${module.artifactory_jcr[0].hostname}/general-docker": ""
  harbor_image_repo      = var.enable_harbor ? "harbor.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}": ""
  ecr_image_repo         = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"

  operator_slack_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = var.operator_slack_service_account_arn
  }
  operator_jenkins_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = var.operator_jenkins_service_account_arn
  }
  operator_product_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = var.product_operator_service_account_arn
  }
  aws_event_mapper_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = var.codeservices_event_mapper_service_account_arn
  }

  product_vars = {
    enable_keycloak         = var.enable_keycloak
    builder_images_version  = var.builder_images_version
    jenkins_image_version   = var.jenkins_image_version
    jenkins_pipeline_source = var.jenkins_pipeline_source
    toolchain_image_repo    = var.toolchain_image_repo
    enable_harbor           = var.enable_harbor
    enable_artifactory_jcr  = var.enable_artifactory_jcr

    s3_bucket                   = var.enable_aws_code_services ? var.codeservices_s3_bucket : ""
    codebuild_role              = var.enable_aws_code_services ? var.codeservices_codebuild_role : ""
    codepipeline_role           = var.enable_aws_code_services ? var.codeservices_pipeline_role : ""
    codebuild_user              = var.enable_aws_code_services ? "codebuild" : ""
    codebuild_security_group_id = var.codeservices_codebuild_security_group_id
    aws_environment             = var.aws_environment

    vault_namespace         = module.vault.vault_namespace
    vault_root_token_secret = module.vault.vault_root_token_secret
  }
}

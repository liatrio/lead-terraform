data "vault_generic_secret" "sparky" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/sparky"
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

provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "sdm" {
  source                      = "../../../../modules/lead/sdm"
  namespace                   = var.namespace
  system_namespace            = var.system_namespace
  root_zone_name              = var.root_zone_name
  cluster                     = var.cluster_id
  sdm_version                 = var.sdm_version
  product_version             = var.product_version
  slack_bot_token             = var.slack_bot_token
  slack_client_signing_secret = var.slack_client_signing_secret
  enable_aws_event_mapper     = false
  toolchain_image_repo        = "489130170427.dkr.ecr.us-east-1.amazonaws.com"
  operators                   = [
    "toolchain",
    "elasticsearch",
    "slack",
    "jenkins"
  ]
  product_types               = [
    "product-jenkins"
  ]

  product_vars      = {
    enable_keycloak        = "TEST"
    builder_images_version = "TEST"
    jenkins_image_version  = "TEST"
    toolchain_image_repo   = "TEST"
    product_image_repo     = "TEST"
    enable_harbor          = "TEST"
    enable_artifactory     = "TEST"

    aws_environment             = "TEST"
    codebuild_security_group_id = "TEST"
    s3_bucket                   = "TEST"
    codebuild_role              = "TEST"
    codepipeline_role           = "TEST"
    codebuild_user              = "TEST"
  }
  ecr_image_repo    = "TEST"
  harbor_image_repo = "TEST"
}

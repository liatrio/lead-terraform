locals {
  product_image_repo = coalesce(
    var.enable_harbor ? "harbor.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}" : "",
    var.enable_artifactory_jcr ? "${module.artifactory_jcr[0].hostname}/general-docker" : ""
  )
}

data "vault_generic_secret" "sparky" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/sparky"
}

data "vault_generic_secret" "sparky_new" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/sparky-new"
}

data "vault_generic_secret" "github_token" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/github"
}

module "essential_toleration" {
  source = "../../../modules/affinity/essential-toleration-values"
}

resource "kubernetes_secret" "image_registry_secret" {
  metadata {
    name      = "sdm-image-registry-secret"
    namespace = var.toolchain_namespace
  }

  data = {
    ".dockerconfigjson" = <<EOF
{
  "auths": {
    "${var.sdm_image_registry}": {
      "auth": "${base64encode("${data.vault_generic_secret.github_token.data["username"]}:${data.vault_generic_secret.github_token.data["token"]}")}"
    }
  }
}
EOF
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "helm_release" "operator_toolchain" {
  repository = "https://liatrio-helm.s3.us-east-1.amazonaws.com/charts"
  timeout    = 120
  name       = "operator-toolchain"
  chart      = "operator-toolchain"
  version    = var.sdm_version
  namespace  = var.toolchain_namespace

  values = [
    templatefile("${path.module}/operator-toolchain-values.tpl", {
      sdm_version                 = var.sdm_version
      cluster                     = var.cluster_name
      namespace                   = var.toolchain_namespace
      cluster_domain              = "${var.cluster_name}.${var.root_zone_name}"
      product_version             = var.product_version
      workspace_role              = var.workspace_role_name
      region                      = var.region
      essential_toleration_values = module.essential_toleration.values

      product_image_repo = local.product_image_repo
      ecr_image_repo     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"

      enable_keycloak         = var.enable_keycloak
      builder_images_version  = var.builder_images_version
      jenkins_image_version   = var.jenkins_image_version
      toolchain_image_repo    = var.toolchain_image_repo
      enable_harbor           = var.enable_harbor
      enable_artifactory_jcr  = var.enable_artifactory_jcr
      jenkins_pipeline_source = var.jenkins_pipeline_source

      s3_bucket                   = var.enable_aws_code_services ? var.codeservices_s3_bucket : ""
      codebuild_role              = var.enable_aws_code_services ? var.codeservices_codebuild_role : ""
      codepipeline_role           = var.enable_aws_code_services ? var.codeservices_pipeline_role : ""
      codebuild_user              = var.enable_aws_code_services ? "codebuild" : ""
      codebuild_security_group_id = var.codeservices_codebuild_security_group_id
      aws_environment             = var.aws_environment

      vault_namespace         = module.vault.vault_namespace
      vault_root_token_secret = module.vault.vault_root_token_secret

      image_repository  = var.toolchain_image_repo
      image_pull_secret = kubernetes_secret.image_registry_secret.metadata[0].name

      remote_state_config = file("./terragrunt-product-backend-s3.hcl")

      enable_aws_event_mapper = var.enable_aws_code_services
      sqs_url                 = var.enable_aws_code_services ? var.codeservices_sqs_url : ""

      operator_toolchain_enabled     = contains(var.lead_sdm_operators, "toolchain")
      operator_elasticsearch_enabled = contains(var.lead_sdm_operators, "elasticsearch")
      operator_slack_enabled         = contains(var.lead_sdm_operators, "slack")
      operator_product_enabled       = contains(var.lead_sdm_operators, "product")

      product_type_aws_enabled     = contains(var.product_types, "product-aws")
      product_type_jenkins_enabled = contains(var.product_types, "product-jenkins")

      slack_service_account_annotations            = jsonencode({
        "eks.amazonaws.com/role-arn" = var.sparky_service_account_arn
      })
      product_service_account_annotations          = jsonencode({
        "eks.amazonaws.com/role-arn" = var.product_operator_service_account_arn
      })
      aws_event_mapper_service_account_annotations = jsonencode({
        "eks.amazonaws.com/role-arn" = var.codeservices_event_mapper_service_account_arn
      })
    })
  ]
}

resource "kubernetes_secret" "operator_slack_config" {
  metadata {
    name      = "operator-slack-config"
    namespace = var.toolchain_namespace

    labels = {
      "app.kubernetes.io/name"       = "operator-slack"
      "app.kubernetes.io/instance"   = "operator-slack"
      "app.kubernetes.io/component"  = "operator-slack"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      "source-repo" = "https://github.com/liatrio/lead-toolchain"
    }
  }

  type = "Opaque"

  data = {
    "slack_config" = <<EOF
clientSigningSecret=${data.vault_generic_secret.sparky.data["slack-signing-secret"]}
botToken=${data.vault_generic_secret.sparky.data["slack-bot-user-oauth-access-token"]}
EOF

  }
}

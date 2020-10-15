module "essential_toleration" {
  source = "../../affinity/essential-toleration-values"
}

data "template_file" "operator_toolchain_values" {
  template = file("${path.module}/operator-toolchain-values.tpl")

  vars = {
    sdm_version                 = var.sdm_version
    cluster                     = var.cluster
    namespace                   = var.namespace
    cluster_domain              = "${var.cluster}.${var.root_zone_name}"
    product_version             = var.product_version
    workspace_role              = var.workspace_role_name
    region                      = var.region
    essential_toleration_values = module.essential_toleration.values

    harbor_image_repo = var.harbor_image_repo
    ecr_image_repo    = var.ecr_image_repo

    enable_keycloak        = var.product_vars["enable_keycloak"]
    builder_images_version = var.product_vars["builder_images_version"]
    jenkins_image_version  = var.product_vars["jenkins_image_version"]
    toolchain_image_repo   = var.product_vars["toolchain_image_repo"]
    enable_harbor          = var.product_vars["enable_harbor"]

    aws_environment             = var.product_vars["aws_environment"]
    s3_bucket                   = var.product_vars["s3_bucket"]
    codebuild_role              = var.product_vars["codebuild_role"]
    codepipeline_role           = var.product_vars["codepipeline_role"]
    codebuild_user              = var.product_vars["codebuild_user"]
    codebuild_security_group_id = var.product_vars["codebuild_security_group_id"]

    vault_namespace         = var.product_vars["vault_namespace"]
    vault_root_token_secret = var.product_vars["vault_root_token_secret"]

    image_repository = var.toolchain_image_repo

    remote_state_config = var.remote_state_config

    enable_aws_event_mapper = var.enable_aws_event_mapper
    sqs_url                 = var.sqs_url

    operator_toolchain_enabled     = contains(var.operators, "toolchain")
    operator_elasticsearch_enabled = contains(var.operators, "elasticsearch")
    operator_slack_enabled         = contains(var.operators, "slack")
    operator_jenkins_enabled       = contains(var.operators, "jenkins")
    operator_product_enabled       = contains(var.operators, "product")

    product_type_aws_enabled     = contains(var.product_types, "product-aws")
    product_type_jenkins_enabled = contains(var.product_types, "product-jenkins")

    slack_service_account_annotations            = jsonencode(var.operator_slack_service_account_annotations)
    jenkins_service_account_annotations          = jsonencode(var.operator_jenkins_service_account_annotations)
    product_service_account_annotations          = jsonencode(var.operator_product_service_account_annotations)
    aws_event_mapper_service_account_annotations = jsonencode(var.aws_event_mapper_service_account_annotations)
  }
}

resource "helm_release" "operator_toolchain" {
  count      = var.enable_operators ? 1 : 0
  repository = "https://liatrio-helm.s3.us-east-1.amazonaws.com/charts"
  timeout    = 120
  name       = "operator-toolchain"
  chart      = "operator-toolchain"
  version    = var.sdm_version
  namespace  = var.namespace

  values = [
    data.template_file.operator_toolchain_values.rendered
  ]
}

resource "kubernetes_secret" "operator_slack_config" {
  metadata {
    name      = "operator-slack-config"
    namespace = var.namespace

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
clientSigningSecret=${var.slack_client_signing_secret}
botToken=${var.slack_bot_token}
EOF

  }
}

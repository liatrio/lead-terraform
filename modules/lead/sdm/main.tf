provider "helm" {
  alias = "system"
}

provider "helm" {
  alias = "toolchain"
}

data "helm_repository" "liatrio" {
  name     = "liatrio"
  url      = "http://liatrio-helm.s3.us-east-1.amazonaws.com/charts"
  provider = helm.toolchain
}

data "template_file" "operator_toolchain_values" {
  template = file("${path.module}/operator-toolchain-values.tpl")

  vars = {
    image_tag       = "v${var.sdm_version}"
    cluster         = var.cluster
    namespace       = var.namespace
    cluster_domain  = "${var.cluster}.${var.root_zone_name}"
    product_version = var.product_version
    workspace_role  = var.workspace_role_name
    region          = var.region
    product_stack   = var.product_stack
    product_vars    = jsonencode(var.product_vars)
    
    enable_aws_event_mapper = var.enable_aws_event_mapper
    code_services_s3_bucket = var.code_services_s3_bucket
    codebuild_role      = var.codebuild_role
    codepipeline_role   = var.codepipeline_role
    codebuild_user      = var.codebuild_user
    
    operator_toolchain_enabled     = contains(var.operators, "toolchain")
    operator_elasticsearch_enabled = contains(var.operators, "elasticsearch")
    operator_slack_enabled         = contains(var.operators, "slack")
    operator_jenkins_enabled       = contains(var.operators, "jenkins")
    operator_product_enabled       = contains(var.operators, "product")

    slack_service_account_annotations   = jsonencode(var.operator_slack_service_account_annotations)
    jenkins_service_account_annotations = jsonencode(var.operator_jenkins_service_account_annotations)
  }
}

resource "helm_release" "operator_toolchain" {
  count      = var.enable_operators ? 1 : 0
  repository = data.helm_repository.liatrio.metadata[0].name
  name       = "operator-toolchain"
  chart      = "operator-toolchain"
  version    = var.sdm_version
  namespace  = var.namespace
  provider   = helm.toolchain

  values = [data.template_file.operator_toolchain_values.rendered]
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

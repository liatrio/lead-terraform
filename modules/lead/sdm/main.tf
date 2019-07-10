provider "helm" {
  alias = "system"
}

provider "helm" {
  alias = "toolchain"
}

data "helm_repository" "liatrio" {
  name = "liatrio"
  url  = "https://artifactory.liatr.io/artifactory/helm/"
}

resource "helm_release" "operator_toolchain_definition" {
  repository = data.helm_repository.liatrio.metadata[0].name
  name       = "operator-toolchain-definition"
  chart      = "operator-toolchain-definition"
  version    = var.sdm_version
  namespace  = var.system_namespace
  provider   = helm.system
}

data "template_file" "operator_toolchain_values" {
  template = file("${path.module}/operator-toolchain-values.tpl")

  vars = {
    image_tag      = "v${var.sdm_version}"
    namespace      = var.namespace
    cluster_domain = "${var.cluster}.${var.root_zone_name}"
    workspace_role = var.workspace_role_name
    region         = var.region
  }
}

resource "helm_release" "operator_toolchain" {
  repository = data.helm_repository.liatrio.metadata[0].name
  name       = "operator-toolchain"
  chart      = "operator-toolchain"
  version    = var.sdm_version
  namespace  = var.namespace
  provider   = helm.toolchain
  depends_on = [helm_release.operator_toolchain_definition]

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


data "kubernetes_secret" "product-harbor-creds" {
  count = var.enable_harbor ? 1 : 0
  provider = kubernetes.toolchain
  metadata {
    name      = "${var.product_name}-harbor-credentials"
    namespace = "toolchain"
  }
}

provider "harbor" {}

resource "harbor_project" "project" {
  name = var.product_name
}

resource "harbor_robot_account" "robot" {
  name = "robot$imagepusher"
  project_id = harbor_project.project.id
  robot_account_access {
    resource = "image"
    action = "pull"
  }
  robot_account_access {
    resource = "image"
    action = "push"
  }
  robot_account_access {
    resource = "helm-chart"
    action = "pull"
  }
  robot_account_access {
    resource = "helm-chart"
    action = "push"
  }
}

resource "kubernetes_secret" "harbor_robot_token" {
  metadata {
    name = "${var.product_name}-harbor-credentials"
    namespace = var.toolchain_namespace
  }

  type = "Opaque"

  data = {
    AUTH = harbor_robot_account.tobot.token
  }
}

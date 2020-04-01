locals {
  protocol = var.cluster_domain == "docker-for-desktop.localhost" ? "http" : "https"
}

provider "kubernetes" {
  alias = "toolchain"
}

provider "helm" {
  alias = "toolchain"
}

provider "kubernetes" {
  alias = "staging"
}

provider "helm" {
  alias = "staging"
}

provider "kubernetes" {
  alias = "production"
}

provider "helm" {
  alias = "production"
}

provider "kubernetes" {
  alias = "system"
}

data "kubernetes_secret" "harbor_admin_creds" {
  provider = kubernetes.system
  metadata {
    name      = "harbor-harbor-core"
    namespace = var.toolchain_namespace
  }
}

provider "harbor" {
  url      = "https://harbor.${var.toolchain_namespace}.${var.cluster_domain}"
  username = "admin"
  password = data.kubernetes_secret.harbor_admin_creds.data.HARBOR_ADMIN_PASSWORD
}

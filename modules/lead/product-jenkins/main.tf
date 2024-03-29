locals {
  protocol         = var.cluster_domain == "docker-for-desktop.localhost" ? "http" : "https"
  ingress_hostname = "${module.toolchain_namespace.name}.jenkins.${var.cluster_domain}"
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

provider "helm" {
  alias = "system"
}

data "kubernetes_secret" "harbor_admin_creds" {
  provider = kubernetes.system
  metadata {
    name      = "harbor-core"
    namespace = var.toolchain_namespace
  }
}

provider "harbor" {
  url      = "https://harbor.${var.toolchain_namespace}.${var.cluster_domain}"
  username = "admin"
  password = var.enable_harbor ? data.kubernetes_secret.harbor_admin_creds.data.HARBOR_ADMIN_PASSWORD : ""
}

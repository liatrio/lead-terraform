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

  override = [
    "metadata.annotations.sidecar\\.istio\\.io/inject=false"
  ]
}

provider "kubernetes" {
  alias = "production"
}

provider "helm" {
  alias = "production"

  override = [
    "metadata.annotations.sidecar\\.istio\\.io/inject=false"
  ]
}

provider "kubernetes" {
  alias = "system"
}

provider "helm" {
  alias = "system"
}

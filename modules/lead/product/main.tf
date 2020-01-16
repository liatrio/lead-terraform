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
  namespace = module.staging_namespace.name

  override = [
    "metadata.annotations.sidecar\\.istio\\.io/inject=false"
  ]
}

provider "kubernetes" {
  alias = "production"
}

provider "helm" {
  alias = "production"
  namespace = module.production_namespace.name

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

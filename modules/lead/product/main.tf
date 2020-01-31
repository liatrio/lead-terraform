locals {
  protocol = var.cluster_domain == "docker-for-desktop.localhost" ? "http" : "https"
  image_repo_url = "${var.image_repository}.toolchain.${var.cluster_domain}"
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

  namespace                       = module.staging_namespace.name
  service_account                 = module.staging_namespace.tiller_service_account
  automount_service_account_token = true

  override = [
    "spec.template.metadata.annotations.sidecar\\.istio\\.io/inject=false"
  ]
}

provider "kubernetes" {
  alias = "production"
}

provider "helm" {
  alias = "production"

  namespace                       = module.production_namespace.name
  service_account                 = module.production_namespace.tiller_service_account
  automount_service_account_token = true

  override = [
    "spec.template.metadata.annotations.sidecar\\.istio\\.io/inject=false"
  ]
}

provider "kubernetes" {
  alias = "system"
}

provider "helm" {
  alias = "system"
}

provider "kubernetes" {
  alias = "staging"
  load_config_file = "false"
}

provider "helm" {
  version = "0.10.4"
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
  load_config_file = "false"
}

provider "helm" {
  version = "0.10.4"
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
  load_config_file = "false"
}

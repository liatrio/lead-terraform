module "system_namespace" {
  source    = "../../common/namespace"
  namespace = var.namespace
  annotations = {
    name    = var.namespace
    cluster = var.cluster
  }
  labels = {
    "openpolicyagent.org/webhook"           = "ignore"
  }
}

module "opa" {
  enable_opa         = var.enable_opa
  source             = "../../common/opa"
  namespace          = module.system_namespace.name
  opa_failure_policy = var.opa_failure_policy
  external_values    = var.essential_toleration_values
}

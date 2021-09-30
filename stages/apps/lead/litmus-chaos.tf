module "litmus_namespace" {
  source    = "../../../modules/common/namespace"

  namespace = module.litmus_namespace.name
  annotations = {
    name    = module.litmus_namespace.name
    cluster = var.cluster_name
  }
}

module "litmus_chaos" {
  source = "../../../modules/tools/litmus-chaos"

  litmus_hostname            = "litmus.${local.internal_ingress_hostname}"
  litmus_ingress_annotations = local.internal_ingress_annotations
}

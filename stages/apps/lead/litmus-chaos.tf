module "litmus_namespace" {
  source    = "../../../modules/common/namespace"

  namespace = var.litmus_namespace
  annotations = {
    name    = var.litmus_namespace
    cluster = var.cluster_name
  }
}

module "litmus_chaos" {
  source = "../../../modules/tools/litmus-chaos"

  litmus_hostname            = "litmus.${local.internal_ingress_hostname}"
  litmus_ingress_annotations = local.internal_ingress_annotations
}


# Litmus
module "litmus_namespace" {
  count  = var.enable_litmus ? 1 : 0
  source = "../../../modules/common/namespace"

  namespace = var.litmus_namespace
  annotations = {
    name    = var.litmus_namespace
    cluster = var.cluster_name
  }
}

module "litmus_chaos" {
  count  = var.enable_litmus ? 1 : 0
  source = "../../../modules/tools/litmus-chaos"

  litmus_namespace = module.litmus_namespace[0].name
  litmus_hostname  = "litmus.${local.internal_ingress_hostname}"
}

# Chaos Mesh
module "chaos_mesh_namespace" {
  count     = var.enable_chaos_mesh ? 1 : 0
  source    = "../../../modules/common/namespace"
  namespace = var.chaos_mesh_namespace
  annotations = {
    name    = var.chaos_mesh_namespace
    cluster = var.cluster_name
  }
}

module "chaos_mesh" {
  count  = var.enable_chaos_mesh ? 1 : 0
  source = "../../../modules/tools/chaos-mesh"

  chaos_mesh_namespace           = module.chaos_mesh_namespace[0].name
  chaos_mesh_hostname            = "chaos-mesh.${local.internal_ingress_hostname}"
  chaos_mesh_ingress_annotations = local.internal_ingress_annotations
}

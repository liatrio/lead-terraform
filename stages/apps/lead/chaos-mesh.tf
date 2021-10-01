module "chaos_mesh_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = var.chaos_mesh_namespace
  annotations = {
    name    = var.chaos_mesh_namespace
    cluster = var.cluster_name
  }
}

module "chaos_mesh" {
  source = "../../../modules/tools/chaos-mesh"

  chaos_mesh_namespace = module.chaos_mesh_namespace.name
  chaos_mesh_hostname            = "chaos-mesh.${local.internal_ingress_hostname}"
  chaos_mesh_ingress_annotations = local.internal_ingress_annotations
}

terraform {
    source = "../../../../stages/apps/azure-example"
}

include {
  path = find_in_parent_folders()
}

dependency "kubernetes_cluster" {
    config_path = "../cloud-provider"
}

inputs = {
    resource_group_name = dependency.kubernetes_cluster.outputs.resource_group_name
    cluster_name = dependency.kubernetes_cluster.outputs.cluster_name
}
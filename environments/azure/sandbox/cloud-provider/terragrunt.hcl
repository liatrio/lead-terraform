terraform {
  source = "../../../../stages/cloud-provider/azure/lead"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  resource_group_name = "lead"
  prefix              = "lead"
  location            = "Central US"
  cluster_name        = "lead-k8s"
  pool_name           = "default"
  node_count          = 1
  vm_size             = "Standard_DS2_v2"
}
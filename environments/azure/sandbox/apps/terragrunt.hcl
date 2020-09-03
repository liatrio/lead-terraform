terraform {
    source = "../../../../stages/apps/azure-example"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  resource_group = "lead"
  subnet_id = dependency.cloud_provider.outputs.subnet_id
}

dependency "cloud_provider" {
    config_path = "../cloudprovider"
}

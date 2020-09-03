terraform {
    source = "../../../../stages/cloud-provider/azure/lead"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  resource_group = "lead"
}
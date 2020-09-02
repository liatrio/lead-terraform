terraform {
    source = "../../../../stacks/environment-azure"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  resource_group = "lead"
}
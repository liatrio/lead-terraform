terraform {
    source = "../../../../stacks/environment-azure"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  rg_name                 = "rg-????"
  location                = "???"
  }
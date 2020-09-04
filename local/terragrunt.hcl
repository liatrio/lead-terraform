# Configure Terragrunt to store tfstate files
remote_state {
  backend = "local"
  generate = {
    path      = "main.tf"
    if_exists = "overwrite"
    contents = file("${get_parent_terragrunt_dir()}/${path_relative_to_include()}/local_main.tf")
  }
  config = {
    path = "terraform.tfstate"
  }
}

root_zone_name = "localhost"
cluster = "docker-for-desktop"
product_name = "local"

terragrunt = {
  remote_state {
    backend = "local"
    config { path = "terraform.tfstate" }
  }

  terraform {
    source = "../..//stacks/product-local"
    extra_arguments "shared_vars" {
      commands = ["${get_terraform_commands_that_need_vars()}"]
      optional_var_files = [
          "${get_parent_tfvars_dir()}/../secrets/${path_relative_to_include()}.tfvars",
      ]
    }

  }

}
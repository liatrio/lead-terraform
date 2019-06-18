product_name = "local"
issuer_type = "selfSigned"
ingress_controller_type = "NodePort"
load_config_file = true
config_context = "docker-for-desktop"
cluster_domain = "docker-for-desktop.localhost"

terragrunt = {
  remote_state {
    backend = "local"
    config { path = "terraform.tfstate" }
  }

  terraform {
    source = "../..//stacks/product-aws"
    extra_arguments "shared_vars" {
      commands = ["${get_terraform_commands_that_need_vars()}"]
      optional_var_files = [
          "${get_parent_tfvars_dir()}/../secrets/${path_relative_to_include()}.tfvars",
      ]
    }

  }

}
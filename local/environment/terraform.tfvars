terragrunt = {
  remote_state {
    backend = "local"
    config { path = "terraform.tfstate" }
  }

  terraform {
    source = "../..//stacks/environment-local"
    extra_arguments "shared_vars" {
      commands = ["${get_terraform_commands_that_need_vars()}"]
      optional_var_files = [
          "${get_tfvars_dir()}/../../secrets/docker-for-desktop.tfvars",
      ]
    }

  }
}

root_zone_name = "localhost"
cluster = "docker-for-desktop"

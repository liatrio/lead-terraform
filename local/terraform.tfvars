terragrunt = {

# Removed until s3 backend is scoped to AWS only.
# TODO: Rescope env for more sets/providers
#  include {
#    path = "${find_in_parent_folders()}"
#  }

# Including stacks directly as workaround for ^
  terraform {
    source = "../..//stacks/environment-local"
    extra_arguments "shared_vars" {
      commands = ["${get_terraform_commands_that_need_vars()}"]
      optional_var_files = [
          "${get_parent_tfvars_dir()}/../secrets/${path_relative_to_include()}.tfvars",
      ]
    }
  }
}

root_zone_name = "localhost"

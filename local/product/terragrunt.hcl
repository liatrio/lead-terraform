# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
    source = "../..//stacks/product-local"
    extra_arguments "shared_vars" {
      commands = get_terraform_commands_that_need_vars()
      optional_var_files = [
          "${get_parent_terragrunt_dir()}/../secrets/${path_relative_to_include()}.tfvars",
      ]
    }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  product_name = "local"
  issuer_type = "selfSigned"
  ingress_controller_type = "NodePort"
  load_config_file = true
  config_context = "docker-for-desktop"
  cluster_domain = "docker-for-desktop.localhost"
  builder_images_version = "v1.0.15-9-g28caba1"
  jenkins_image_version = "v1.0.15-9-g28caba1"
  image_repo = "artifactory.toolchain.lead.prod.liatr.io/docker-registry/flywheel"
}

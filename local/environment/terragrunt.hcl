# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../..//stacks/environment-local"
  extra_arguments "shared_vars" {
    commands = get_terraform_commands_that_need_vars()
    optional_var_files = [
        "${get_parent_terragrunt_dir()}/../secrets/docker-for-desktop.tfvars",
    ]
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  root_zone_name  = "localhost"
  cluster         = "docker-for-desktop"
  sdm_version     = "0.4.0-212-g6a776a7"

  builder_images_version = "v1.0.16-7-g7c121bb"
  jenkins_image_version = "v1.0.16-3-g541d352"

  enable_artifactory = true
  enable_gitlab      = false
  enable_istio       = false
  enable_grafeas     = false
  enable_keycloak    = false
  enable_mailhog     = false
  enable_operators   = true
  enable_sonarqube   = false
  enable_xray        = false

  # This will conflict with Istio since it's also configured as a LoadBalancer
  # So ensure `enable_istio = false` before uncommenting this
  # ingress_controller_type         = "LoadBalancer"
  # ingress_external_traffic_policy = "Local"
}

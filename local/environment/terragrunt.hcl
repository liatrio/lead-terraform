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

  toolchain_image_repo = "489130170427.dkr.ecr.us-east-1.amazonaws.com"

  enable_artifactory       = false
  enable_gitlab            = false
  enable_istio             = false
  enable_keycloak          = false
  enable_operators         = true
  enable_sonarqube         = false
  enable_dashboard         = false
  enable_harbor            = false
  enable_aws_code_services = false

  # This will conflict with Istio since it's also configured as a LoadBalancer
  # So ensure `enable_istio = false` before uncommenting this
  # ingress_controller_type         = "LoadBalancer"
  # ingress_external_traffic_policy = "Local"
}

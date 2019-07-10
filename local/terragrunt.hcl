# Configure Terragrunt to store tfstate files
remote_state {
  backend = "local"
  config = { 
    path = "terraform.tfstate" 
  }
}

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = {
  aws_region  = "us-east-1"
  aws_profile = "prod"
}
# Configure Terragrunt to store tfstate files
remote_state {
  backend = "local"
  config = {
    path = "terraform.tfstate"
  }
}

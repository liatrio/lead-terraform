
terraform {
  required_version = ">= 0.12"
  required_providers {
    harbor = {
      source = "liatrio/harbor"
      version = "= 0.3.2"
    }
  }
}

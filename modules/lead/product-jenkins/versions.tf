
terraform {
  required_version = ">= 0.13.1"
  required_providers {
    harbor = {
      source = "liatrio/harbor"
      version = "= 0.3.2"
    }
  }
}

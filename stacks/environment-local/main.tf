# Common Data and Providers

# Using Local State Only!

terraform {
  backend "local" {
  }
}

# Use an existing named kubectl context specified as `cluster` in variables.tf or tfvars file (eg, minikube/d4d)
provider "kubernetes" {
  config_context = var.cluster
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_context = var.cluster
  }
}

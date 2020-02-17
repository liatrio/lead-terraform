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
  version         = "0.10.4"
  alias           = "system"
  namespace       = module.infrastructure.namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.infrastructure.tiller_service_account

  kubernetes {
    config_context = var.cluster
  }

  override = [
    "spec.template.spec.containers[0].resources.limits.memory=128Mi",
    "spec.template.spec.containers[0].resources.requests.memory=64Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=200m",
    "spec.template.spec.containers[0].resources.requests.cpu=50m",
  ]
}

provider "helm" {
  version         = "0.10.4"
  alias           = "toolchain"
  namespace       = module.toolchain.namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.toolchain.tiller_service_account

  kubernetes {
    config_context = var.cluster
  }

  override = [
    "spec.template.spec.containers[0].resources.limits.memory=128Mi",
    "spec.template.spec.containers[0].resources.requests.memory=64Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=200m",
    "spec.template.spec.containers[0].resources.requests.cpu=50m",
  ]
}


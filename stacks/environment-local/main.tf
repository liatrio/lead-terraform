# Common Data and Providers

# Using Local State Only!

terraform {
  backend "local" {}
}

# Use an existing named kubectl context specified as `cluster` in variables.tf or tfvars file (eg, minikube/d4d)
provider "kubernetes" {
  config_context = "${var.cluster}"
}

provider "helm" {
  alias           = "system"
  namespace       = "${module.infrastructure.namespace}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "${module.infrastructure.tiller_service_account}"

  kubernetes {
    config_context = "${var.cluster}"
  }
}

provider "helm" {
  alias           = "toolchain"
  namespace       = "${module.toolchain.namespace}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "${module.toolchain.tiller_service_account}"

  kubernetes {
    config_context = "${var.cluster}"
  }
}

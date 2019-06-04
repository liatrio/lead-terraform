# Common Data and Providers

# Using Local State Only!

terraform {
  backend "local" {}
}

data "template_file" "external_dns_values" {
  template = "${file("${path.module}/external-dns-values.tpl")}"

  vars = {
    ns_domain = "${var.cluster}.${var.root_zone_name}"
  }
}

# Use an existing named kubectl context specified as `cluster` in variables.tf or tfvars file (eg, minikube/d4d)
provider "kubernetes" {
  config_context_auth_info = "${var.cluster}"
  config_context_cluster   = "${var.cluster}"
}

provider "helm" {
  alias = "system"
  namespace = "${var.system_namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "${module.infrastructure.tiller_service_account}"

  kubernetes {
    config_context = "${var.cluster}"
  }
}

module "infrastructure" {
  source             = "../../modules/lead/infrastructure"
  cluster            = "${var.cluster}"
  namespace          = "${var.system_namespace}"
  enable_opa         = "true"
  opa_failure_policy = "${var.opa_failure_policy}"

  external_dns_chart_values = "${data.template_file.external_dns_values.rendered}"

  providers {
    helm = "helm.system"
  }
}

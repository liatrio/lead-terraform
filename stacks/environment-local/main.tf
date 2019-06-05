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
  config_context = "${var.cluster}"
}

provider "helm" {
  alias = "system"
  namespace = "${module.infrastructure.namespace}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "${module.infrastructure.tiller_service_account}"

  kubernetes {
    config_context = "${var.cluster}"
  }
}

provider "helm" {
  alias = "toolchain"
  namespace = "${module.toolchain.namespace}"
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
  enable_opa         = "false"
  opa_failure_policy = "${var.opa_failure_policy}"

  external_dns_chart_values = "${data.template_file.external_dns_values.rendered}"

  providers {
    helm = "helm.system"
  }
}

module "toolchain" {
  source             = "../../modules/lead/toolchain"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${var.cluster}"
  namespace          = "${var.toolchain_namespace}"
  image_whitelist    = "${var.image_whitelist}"
#  elb_security_group_id = "${aws_security_group.elb.id}"

  providers {
    helm = "helm.toolchain"
  }
}

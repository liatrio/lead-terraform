provider "aws" {
  alias = "toolchain"
  region  = "${var.region}"
}

provider "kubernetes" {
  alias = "toolchain"
}

provider "helm" {
  alias = "toolchain"
  namespace = "${module.toolchain_namespace.name}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "${module.toolchain_namespace.tiller_service_account}"

  kubernetes {
  }
}

data "aws_security_group" "toolchain_elb" {
  tags = {
    Cluster = "${var.cluster}"
    Type = "ingress-elb"
  }
  providers = {
    aws = "aws.toolchain"
  }
}

module "toolchain_namespace" {
  source     = "../../modules/common/namespace"
  namespace  = "${var.product_name}-toolchain"
  annotations {
    name  = "${var.product_name}-toolchain"
    cluster = "${var.cluster}"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-toolchain.${var.cluster}.${var.root_zone_name}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
    "opa.lead.liatrio/elb-extra-security-groups" = "${data.aws_security_group.toolchain_elb.id}"
  }
}

module "toolchain_ingress" {
  source             = "../../modules/aws/ingress"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${var.cluster}"
  namespace          = "${var.product_name}-toolchain"
  elb_security_group_id = "${data.aws_security_group.toolchain_elb.id}"
  providers = {
    aws = "aws.toolchain"
    helm = "helm.toolchain"
    kubernetes = "kubernetes.toolchain"
  }
}

module "product" {
  source             = "../../modules/lead/product"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${var.cluster}"
  namespace          = "${var.product_name}-toolchain"
}
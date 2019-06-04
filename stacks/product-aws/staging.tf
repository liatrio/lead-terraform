provider "aws" {
  alias = "staging"
  region  = "${var.region}"
}

provider "kubernetes" {
  alias = "staging"
}

provider "helm" {
  alias = "staging"
  namespace = "${module.staging_namespace.name}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "${module.staging_namespace.tiller_service_account}"

  kubernetes {
  }
}

data "aws_security_group" "staging_elb" {
  tags = {
    Cluster = "${var.cluster}"
    Type = "ingress-elb"
  }
  provider = "aws.staging"
}

module "staging_namespace" {
  source     = "../../modules/common/namespace"
  namespace  = "${var.product_name}-staging"
  annotations {
    name  = "${var.product_name}-staging"
    cluster = "${var.cluster}"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-staging.${var.cluster}.${var.root_zone_name}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
    "opa.lead.liatrio/elb-extra-security-groups" = "${data.aws_security_group.staging_elb.id}"
  }
}

module "staging_ingress" {
  source             = "../../modules/aws/ingress"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${var.cluster}"
  namespace          = "${var.product_name}-staging"
  elb_security_group_id = "${data.aws_security_group.staging_elb.id}"
  providers = {
    aws = "aws.staging"
    helm = "helm.staging"
    kubernetes = "kubernetes.staging"
  }
}
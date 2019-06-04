provider "aws" {
  alias = "production"
  region  = "${var.region}"
}

provider "kubernetes" {
  alias = "production"
}

provider "helm" {
  alias = "production"
  namespace = "${module.production_namespace.name}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "${module.production_namespace.tiller_service_account}"

  kubernetes {
  }
}

data "aws_security_group" "production_elb" {
  tags = {
    Cluster = "${var.cluster}"
    Type = "ingress-elb"
  }
  provider = "aws.production"
}

module "production_namespace" {
  source     = "../../modules/common/namespace"
  namespace  = "${var.product_name}-production"
  annotations {
    name  = "${var.product_name}-production"
    cluster = "${var.cluster}"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-production.${var.cluster}.${var.root_zone_name}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
    "opa.lead.liatrio/elb-extra-security-groups" = "${data.aws_security_group.production_elb.id}"
  }
}

module "production_ingress" {
  source             = "../../modules/aws/ingress"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${var.cluster}"
  namespace          = "${var.product_name}-production"
  elb_security_group_id = "${data.aws_security_group.production_elb.id}"
  providers = {
    aws = "aws.production"
    helm = "helm.production"
    kubernetes = "kubernetes.production"
  }
}
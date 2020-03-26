locals {
  protocol = var.root_zone_name == "localhost" ? "http" : "https"
}

data "helm_repository" "codecentric" {
  name = "codecentric"
  url  = "https://codecentric.github.io/helm-charts"
}

data "helm_repository" "liatrio" {
  name = "liatrio"
  url  = "https://artifactory.liatr.io/artifactory/helm/"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

module "toolchain_namespace" {
  source    = "../../common/namespace"
  namespace = var.namespace
  annotations = {
    name                                         = var.namespace
    cluster                                      = var.cluster
    "opa.lead.liatrio/ingress-whitelist"         = "*.${var.namespace}.${var.cluster}.${var.root_zone_name}"
    "opa.lead.liatrio/image-whitelist"           = var.image_whitelist
    "opa.lead.liatrio/elb-extra-security-groups" = var.elb_security_group_id
  }
}


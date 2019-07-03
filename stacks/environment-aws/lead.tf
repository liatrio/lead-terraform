data "template_file" "external_dns_values" {
  template = "${file("${path.module}/external-dns-values.tpl")}"

  vars = {
    domain_filter = "${module.eks.cluster_id}.${var.root_zone_name}"
  }
}

module "infrastructure" {
  source             = "../../modules/lead/infrastructure"
  cluster            = "${module.eks.cluster_id}"
  namespace          = "${var.system_namespace}"
  opa_failure_policy = "${var.opa_failure_policy}"
  enable_opa         = "false"
  issuer_type        = "acme"

  external_dns_chart_values = "${data.template_file.external_dns_values.rendered}"

  providers {
    helm = "helm.system"
  }
}

data "template_file" "cluster_autoscaler" {
  template = "${file("${path.module}/cluster-autoscaler-values.tpl")}"

  vars = {
    cluster = "${var.cluster}"
    region = "${var.region}"
  }
}
data "helm_repository" "stable" {
    name = "stable"
    url  = "https://kubernetes-charts.storage.googleapis.com"
}
resource "helm_release" "cluster_autoscaler" {
  name    = "cluster-autoscaler"
  namespace = "${module.infrastructure.namespace}"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart   = "cluster-autoscaler"
  timeout = 600
  wait    = true

  values = ["${data.template_file.cluster_autoscaler.rendered}"]

  provider = "helm.system"
}

module "toolchain" {
  source             = "../../modules/lead/toolchain"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${module.eks.cluster_id}"
  namespace          = "${var.toolchain_namespace}"
  image_whitelist    = "${var.image_whitelist}"
  elb_security_group_id = "${aws_security_group.elb.id}"
  artifactory_license = "${var.artifactory_license}"
  issuer_type        = "acme"
  ingress_controller_type = "LoadBalancer"
  crd_waiter         = "${module.infrastructure.crd_waiter}"

  providers {
    helm = "helm.toolchain"
  }
}
module "sdm" {
  source             = "../../modules/lead/sdm"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${module.eks.cluster_id}"
  namespace          = "${module.toolchain.namespace}"
  system_namespace   = "${module.infrastructure.namespace}"
  sdm_version        = "${var.sdm_version}"
  slack_bot_token          = "${var.slack_bot_token}"
  slack_client_signing_secret     = "${var.slack_client_signing_secret}"
  workspace_role_name = "${aws_iam_role.workspace_role.name}"

  providers {
    "helm.system" = "helm.system"
    "helm.toolchain" = "helm.toolchain"
  }
}
module "dashboard" {
  source             = "../../modules/lead/dashboard"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${module.eks.cluster_id}"
  namespace          = "${module.toolchain.namespace}"
  dashboard_version  = "${var.dashboard_version}"

  providers {
    helm = "helm.toolchain"
  }
}

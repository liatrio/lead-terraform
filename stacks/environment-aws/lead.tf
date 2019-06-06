data "template_file" "external_dns_values" {
  template = "${file("${path.module}/external-dns-values.tpl")}"

  vars = {
    ns_domain = "${module.eks.cluster_id}.${var.root_zone_name}"
  }
}

module "infrastructure" {
  source             = "../../modules/lead/infrastructure"
  cluster            = "${module.eks.cluster_id}"
  namespace          = "${var.system_namespace}"
  opa_failure_policy = "${var.opa_failure_policy}"

  external_dns_chart_values = "${data.template_file.external_dns_values.rendered}"

  providers {
    helm = "helm.system"
  }
}
module "toolchain" {
  source             = "../../modules/lead/toolchain"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${module.eks.cluster_id}"
  namespace          = "${var.toolchain_namespace}"
  image_whitelist    = "${var.image_whitelist}"
  elb_security_group_id = "${aws_security_group.elb.id}"
  artifactory_license = "${var.artifactory_license}"

  providers {
    helm = "helm.toolchain"
  }
}
module "toolchain_ingress" {
  source             = "../../modules/aws/ingress"
  root_zone_name     = "${var.root_zone_name}"
  cluster            = "${module.eks.cluster_id}"
  namespace          = "${module.toolchain.namespace}"
  elb_security_group_id = "${aws_security_group.elb.id}"

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
  slack_clientid     = "${var.slack_clientid}"
  slack_clientsecret = "${var.slack_clientsecret}"
  slack_verification_token = "${var.slack_verification_token}"
  slack_webhook_url        = "${var.slack_webhook_url}"
  slack_access_token       = "${var.slack_access_token}"

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
  bitbucket_token    = "${var.bitbucket_token}"
  jira_token         = "${var.jira_token}"

  providers {
    helm = "helm.toolchain"
  }
}

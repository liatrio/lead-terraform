data "template_file" "external_dns_values" {
  template = "${file("${path.module}/external-dns-values.tpl")}"

  vars = {
    ns_domain = "${var.cluster}.${var.root_zone_name}"
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
  source              = "../../modules/lead/toolchain"
  root_zone_name      = "${var.root_zone_name}"
  cluster             = "${var.cluster}"
  namespace           = "${var.toolchain_namespace}"
  image_whitelist     = "${var.image_whitelist}"
  artifactory_license = "${var.artifactory_license}"

  providers {
    helm = "helm.toolchain"
  }
}

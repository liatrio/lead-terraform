module "gitlab" {
  source = "../../../modules/tools/gitlab"

  count       = var.enable_gitlab ? 1 : 0
  root_domain = "${var.cluster_name}.${var.root_zone_name}"
}

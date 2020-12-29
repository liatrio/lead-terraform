module "gitlab" {
  source = "../../../modules/tools/gitlab"

  enable_gitlab = var.enable_gitlab
  root_domain   = "${var.cluster_name}.${var.root_zone_name}"
}

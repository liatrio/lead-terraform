module "gitlab" {
  source = "../../../modules/tools/gitlab"

  enable_gitlab = var.enable_gitlab
  rood_domain   = var.root_zone_name
}

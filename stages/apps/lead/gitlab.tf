module "gitlab" {
  source = "../../../modules/tools/gitlab"

  enable_gitlab      = var.enable_gitlab
  gitlab_domain_name = var.root_zone_name
}

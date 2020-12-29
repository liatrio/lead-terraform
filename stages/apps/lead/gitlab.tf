module "gitlab" {
  source = "../../../modules/tools/gitlab"

  enable_gitlab = var.enable_gitlab
}

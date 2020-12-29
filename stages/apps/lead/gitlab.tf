module "gitlab" {
  source = "../../../modules/tools/sonarqube"

  enable_gitlab = var.enable_gitlab
}

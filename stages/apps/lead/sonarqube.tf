module "sonarqube" {
  source = "../../modules/tools/sonarqube"

  enable_sonarqube            = var.enable_sonarqube
  namespace                   = var.toolchain_namespace
}


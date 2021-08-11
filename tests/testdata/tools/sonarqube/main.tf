provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "sonarqube" {
  source           = "../../../../modules/tools/sonarqube"
  namespace        = var.namespace
  enable_sonarqube = var.enable_sonarqube
}
provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

provider "harbor" {
  url      = "http://${var.harbor_hostname}"
  username = "admin"
  password = var.harbor_admin_password
}

// keycloak resources are disabled in this test but we need a provider with minimal config to keep TF happy
provider "keycloak" {
  client_id     = "admin-cli"
  url           = "http://localhost"
  username      = "username"
  password      = "password"
  initial_login = false
}

module "harbor" {
  source            = "../../../../modules/config/harbor"
  enable            = true
  namespace         = var.namespace
  admin_password    = var.admin_password
  hostname          = var.hostname
  enable_keycloak   = false
  keycloak_hostname = ""
  keycloak_realm    = ""
}

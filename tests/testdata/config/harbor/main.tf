provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}

provider "harbor" {
  url      = "http://${var.hostname}"
  username = "admin"
  password = var.admin_password
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
  namespace         = var.namespace
  admin_password    = var.admin_password
  hostname          = var.hostname
  enable_keycloak   = false
  keycloak_hostname = ""
  keycloak_realm    = ""
}

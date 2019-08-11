
data "kubernetes_secret" "keycloak_admin_credential" {
  provider = kubernetes.toolchain

  metadata {
    name      = "keycloak-admin-credential"
    namespace = "toolchain"
  }
}

data "kubernetes_secret" "keycloak_toolchain_realm" {
  provider = kubernetes.toolchain

  metadata {
    name      = "keycloak-toolchain-realm"
    namespace = "toolchain"
  }
}

provider "keycloak" {
  client_id     = "admin-cli"
  username      = data.kubernetes_secret.keycloak_admin_credential.data.username
  password      = data.kubernetes_secret.keycloak_admin_credential.data.password
  url           = "${local.protocol}://keycloak.toolchain.${var.cluster_domain}"
  initial_login = true
}

resource "keycloak_openid_client" "jenkins_openid_client" {
  count                   = var.keycloak_enabled ? 1 : 0
  realm_id                = data.kubernetes_secret.keycloak_toolchain_realm.data.id
  client_id               = "jenkins.${module.toolchain_namespace.name}.${var.cluster_domain}"
  name                    = "Jenkins - ${title(module.toolchain_namespace.name)}"
  access_type             = "PUBLIC"
  standard_flow_enabled   = true
  valid_redirect_uris     = ["https://jenkins.${module.toolchain_namespace.name}.${var.cluster_domain}:32386/securityRealm/finishLogin"]
}


resource "keycloak_openid_user_property_protocol_mapper" "jenkins_openid_user_property_mapper_email" {
  count                      = var.keycloak_enabled ? 1 : 0
  realm_id                   = data.kubernetes_secret.keycloak_toolchain_realm.data.id
  client_id                  = keycloak_openid_client.jenkins_openid_client[0].id
  name                       = "email"

  user_property              = "email"
  claim_name                 = "email"
}
  
resource "kubernetes_config_map" "jenkins_keycloak_config" {
  provider   = kubernetes.toolchain
  depends_on = [helm_release.jenkins]
  metadata {
    name      = "jenkins-jenkins-config-security-config"
    namespace = module.toolchain_namespace.name
  }

  data = {
    "security-config.yaml" = <<EOF
jenkins:
  securityRealm: keycloak
  authorizationStrategy: loggedInUsersCanDoAnything  
keycloakSecurityRealm:
  keycloakJson: >
    {
      "realm": "toolchain",
      "auth-server-url": "https://keycloak.toolchain.${var.cluster_domain}/auth",
      "ssl-required": "external",
      "resource": "jenkins.${module.toolchain_namespace.name}.${var.cluster_domain}",
      "public-client": true
    }
EOF
  }
}

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
  initial_login = false
}

resource "keycloak_openid_client" "jenkins_openid_client" {
  count                   = var.enable_keycloak? 1 : 0
  realm_id                = data.kubernetes_secret.keycloak_toolchain_realm.data.id
  client_id               = "jenkins.${module.toolchain_namespace.name}.${var.cluster_domain}"
  name                    = "Jenkins - ${title(module.toolchain_namespace.name)}"
  access_type             = "PUBLIC"
  standard_flow_enabled   = true
  valid_redirect_uris     = [
    "http://localhost:8080/securityRealm/finishLogin",  # for local environment port forwarding
    "${local.protocol}://jenkins.${module.toolchain_namespace.name}.${var.cluster_domain}/securityRealm/finishLogin" # for dns routable or via ingress
  ]
}


resource "keycloak_openid_user_property_protocol_mapper" "jenkins_openid_user_property_mapper_email" {
  count                      = var.enable_keycloak? 1 : 0
  realm_id                   = data.kubernetes_secret.keycloak_toolchain_realm.data.id
  client_id                  = keycloak_openid_client.jenkins_openid_client[0].id
  name                       = "email"

  user_property              = "email"
  claim_name                 = "email"
}
  
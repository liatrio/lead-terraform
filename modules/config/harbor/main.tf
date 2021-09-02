resource "keycloak_openid_client" "harbor_client" {
  count     = var.enable_keycloak ? 1 : 0
  realm_id  = var.keycloak_realm
  client_id = "harbor"
  name      = "harbor"
  enabled   = true

  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true

  valid_redirect_uris = [
    "https://${var.hostname}/c/oidc/callback"
  ]
}

resource "keycloak_openid_group_membership_protocol_mapper" "harbor_group_membership_mapper" {
  count     = var.enable_keycloak ? 1 : 0
  realm_id  = keycloak_openid_client.harbor_client[0].realm_id
  client_id = keycloak_openid_client.harbor_client[0].id
  name      = "harbor-group-membership-mapper"

  claim_name = "groups"
}

resource "helm_release" "harbor_config" {
  count     = var.enable_keycloak ? 1 : 0
  chart     = "${path.module}/charts/harbor-config"
  name      = "harbor-config"
  namespace = var.namespace
  wait      = true

  set {
    name  = "harbor.username"
    value = "admin"
  }

  set_sensitive {
    name  = "harbor.password"
    value = var.admin_password
  }

  set {
    name  = "harbor.hostname"
    value = var.hostname
  }

  set {
    name  = "keycloak.hostname"
    value = var.keycloak_hostname
  }

  set_sensitive {
    name  = "keycloak.secret"
    value = keycloak_openid_client.harbor_client[0].client_secret
  }

  set {
    name  = "keycloak.realm"
    value = var.keycloak_realm
  }
}

resource "harbor_project" "liatrio_project" {
  name      = "liatrio"
  public    = true
  auto_scan = false
}

resource "harbor_robot_account" "liatrio_project_robot_account" {
  name       = "robot$imagepusher"
  project_id = harbor_project.liatrio_project.id
  access {
    resource = "image"
    action   = "pull"
  }

  access {
    resource = "image"
    action   = "push"
  }
}

resource "kubernetes_secret" "liatrio_project_robot_account_credentials" {
  metadata {
    name      = "liatrio-harbor-project-robot-account-credentials"
    namespace = var.namespace
  }
  type = "Opaque"

  data = {
    username = harbor_robot_account.liatrio_project_robot_account.name
    password = harbor_robot_account.liatrio_project_robot_account.token
  }
}

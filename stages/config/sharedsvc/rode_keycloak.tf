locals {
  roles = toset([
    "Collector",
    "Enforcer",
    "ApplicationDeveloper",
    "PolicyDeveloper",
    "PolicyAdministrator",
    "Administrator"
  ])
}

resource "keycloak_openid_client" "rode" {
  realm_id  = keycloak_realm.sharedsvc.id
  client_id = var.rode_oidc_client_id

  name    = "rode"
  enabled = true

  client_secret = data.vault_generic_secret.rode.data["oidc_client_secret"]

  standard_flow_enabled = true

  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://${var.rode_ui_hostname}/",
    "https://${var.rode_ui_hostname}/callback"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "rode_audience" {
  realm_id  = keycloak_realm.sharedsvc.id
  client_id = keycloak_openid_client.rode.id
  name      = "rode-audience-mapper"

  included_client_audience = keycloak_openid_client.rode.client_id
}

resource "keycloak_role" "rode_roles" {
  for_each = local.roles

  realm_id  = keycloak_realm.sharedsvc.id
  client_id = keycloak_openid_client.rode.id
  name      = each.key
}

resource "keycloak_group" "rode_groups" {
  for_each = local.roles

  realm_id = keycloak_realm.sharedsvc.id
  name     = "Rode ${each.key}s"
}

resource "keycloak_group_roles" "rode_group_roles" {
  for_each = local.roles

  realm_id = keycloak_realm.sharedsvc.id
  group_id = keycloak_group.rode_groups[each.key].id

  role_ids = [
    keycloak_role.rode_roles[each.key].id,
  ]
}

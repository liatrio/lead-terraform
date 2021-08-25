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

resource "keycloak_openid_client" "rode_terraform" {
  realm_id  = keycloak_realm.sharedsvc.id
  client_id = "rode-terraform"
  name      = "Rode Terraform"
  enabled   = true

  client_secret            = data.vault_generic_secret.rode.data["terraform_client_secret"]
  service_accounts_enabled = true
  access_type              = "CONFIDENTIAL"
}

resource "keycloak_openid_audience_protocol_mapper" "rode_terraform_audience" {
  realm_id  = keycloak_realm.sharedsvc.id
  client_id = keycloak_openid_client.rode_terraform.id
  name      = "rode-terraform-audience-mapper"

  included_client_audience = keycloak_openid_client.rode.client_id
}

resource "keycloak_openid_client_service_account_role" "rode_terraform_service_account_role" {
  realm_id                = keycloak_realm.sharedsvc.id
  service_account_user_id = keycloak_openid_client.rode_terraform.service_account_user_id
  client_id               = keycloak_openid_client.rode.id
  role                    = keycloak_role.rode_roles["PolicyAdministrator"].name
}

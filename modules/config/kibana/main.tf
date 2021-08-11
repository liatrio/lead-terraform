resource "keycloak_openid_client" "kibana_client" {
  count                 = var.enable_keycloak ? 1 : 0
  realm_id              = var.keycloak_realm
  client_id             = "kibana"
  name                  = "kibana"
  enabled               = true
  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true

  valid_redirect_uris = [
    "https://${var.kibana_hostname}/oauth/callback"
  ]

}

resource "keycloak_openid_audience_protocol_mapper" "audience_mapper" {
  count     = var.enable_keycloak ? 1 : 0
  realm_id  = keycloak_openid_client.kibana_client[0].realm_id
  client_id = keycloak_openid_client.kibana_client[0].id
  name      = "audience-mapper"

  included_client_audience = keycloak_openid_client.kibana_client[0].client_id
}

resource "helm_release" "gatekeeper" {
  count     = var.enable_keycloak ? 1 : 0
  name      = "gatekeeper"
  namespace = var.namespace
  chart     = "${path.module}/charts/gatekeeper"
  wait      = true
  values = [
    templatefile("${path.module}/gatekeeper-values.tpl", {
      port            = 3000
      client_id       = keycloak_openid_client.kibana_client[0].client_id
      client_secret   = keycloak_openid_client.kibana_client[0].client_secret
      discovery_url   = "https://${var.keycloak_hostname}/auth/realms/${var.keycloak_realm}"
      upstream_port   = 5601
      upstream_host   = "kibana-kibana"
      kibana_hostname = var.kibana_hostname
    })
  ]
}

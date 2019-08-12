data "template_file" "dashboard_keycloak_proxy_values" {
  template = file("${path.module}/dashboard-keycloak-proxy-values.tpl")

  vars = {
    ssl_redirect           = var.root_zone_name == "localhost" ? false : true
    ingress_hostname       = "keycloak-proxy.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    dashboard_url          = "http://dashboard.${module.toolchain_namespace.name}.svc.cluster.local"
    keycloak_realm         = module.toolchain_namespace.name
    keycloak_url           = "${locals.protocol}://keycloak.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}/auth"
    keycloak_client        = "dashboard.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    keycloak_client_secret = random_string.dashboard_openid_client_secret.value
  }
}

resource "random_string" "dashboard_openid_client_secret" {
  length  = 32
  special = false
}

resource "helm_release" "dashboard" {
  count      = var.enable_dashboard ? 1 : 0
  name       = "kubernetes-dashboard"
  namespace  = module.toolchain_namespace.name
  chart      = "stable/kubernetes-dashboard"
  version    = "5.0.1"
  timeout    = 1200
}

resource "helm_release" "dashboard_keycloak_proxy" {
  count      = var.enable_keycloak ? 1 : 0
  name       = "keycloak-proxy"
  namespace  = module.toolchain_namespace.name
  chart      = "incubator/keycloak-proxy"
  version    = "5.0.1"
  timeout    = 1200

  values = [data.template_file.dashboard_keycloak_proxy_values.rendered]
}

resource "keycloak_openid_client" "dashboard_openid_client" {
  depends_on              = [helm_release.keycloak]
  count                   = var.keycloak_enabled ? 1 : 0
  realm_id                = data.kubernetes_secret.keycloak_toolchain_realm.data.id
  client_id               = "dashboard.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  client_secret           = random_string.dashboard_openid_client_secret.value
  name                    = "Dashboard - ${title(module.toolchain_namespace.name)}"
  access_type             = "CONFIDENTIAL"
  standard_flow_enabled   = true
  valid_redirect_uris     = [
    "http://localhost:8080/oauth/callback",  # for local environment port forwarding
    "${local.protocol}://keycloak-proxy.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}/oauth/callback" # for dns routable or via ingress
  ]
}

resource "keycloak_openid_group_membership_protocol_mapper" "group_membership_mapper" {
  depends_on                 = [helm_release.keycloak]
  count                      = var.keycloak_enabled ? 1 : 0
  realm_id                   = data.kubernetes_secret.keycloak_toolchain_realm.data.id
  client_id                  = keycloak_openid_client.dashboard_openid_client[0].id
  name                       = "groups"
  claim_name                 = "groups"
}

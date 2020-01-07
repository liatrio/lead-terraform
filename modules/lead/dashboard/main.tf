locals {
  protocol = var.cluster_domain == "docker-for-desktop.localhost" ? "http" : "https"
}

provider "kubernetes" {
}


data "kubernetes_secret" "keycloak_admin_credential" {
  provider = kubernetes
 
  metadata {
    name      = "keycloak-admin-credential"
    namespace = "toolchain"
  }
}
 
provider "keycloak" {
  client_id     = "admin-cli"
  username      = var.enable_keycloak ? data.kubernetes_secret.keycloak_admin_credential.data.username : "username"
  password      = var.enable_keycloak ? data.kubernetes_secret.keycloak_admin_credential.data.password : "password"
  url           = "${local.protocol}://keycloak.${var.namespace}.${var.cluster}.${var.root_zone_name}"
  initial_login = false
}


data "template_file" "dashboard_values" {
  template = file("${path.module}/dashboard-values.tpl")

  vars = {
    cluster_domain = "${var.namespace}.${var.cluster}.${var.root_zone_name}"
    namespace      = var.namespace
    local          = var.local
    elasticsearch-certs = "${module.elasticsearch-certificate.cert_name}-certificate"

    kibana-hostname = "kibana.${var.namespace}.${var.cluster}.${var.root_zone_name}"

    client-id      = keycloak_openid_client.kibana_client[0].client_id
    client-secret  = keycloak_openid_client.kibana_client[0].client_secret
    discovery-url  = "https://keycloak.${var.namespace}.${var.cluster}.${var.root_zone_name}/auth/realms/${var.keycloak_realm_id}"
    listen         = 3000
    upstream-url   = "http://lead-dashboard-kibana:5601"

    keycloak-enabled = var.enable_keycloak ? true : false
    proxy-certs    = "proxy-ingress-tls"
    k8s_storage_class  = var.k8s_storage_class
  }
}

module "ca-issuer" {
  source = "../../common/ca-issuer"
 
  enabled   = var.enable_keycloak
  name      = "elasticstack"
  namespace = var.namespace
  common_name = var.root_zone_name
  cert-manager-crd = var.crd_waiter
}

module "elasticsearch-certificate" {
  source = "../../common/certificates"
 
  enabled         = var.enabled
  name            = "elasticsearch-certs"
  namespace       = var.namespace
  domain          = "elasticsearch-master.${var.namespace}.svc"
  issuer_name     = module.ca-issuer.name
  certificate_crd = var.crd_waiter
  wait_for_cert   = true
}

data "helm_repository" "liatrio" {
  name = "lead.prod.liatr.io"
  url  = "https://artifactory.toolchain.lead.prod.liatr.io/artifactory/helm/"
}

resource "helm_release" "lead-dashboard" {
  count      = var.enabled ? 1 : 0
  repository = data.helm_repository.liatrio.metadata[0].name
  name       = "lead-dashboard"
  namespace  = var.namespace
  chart      = "lead-dashboard"
  version    = var.dashboard_version
  timeout    = 900

  values = [data.template_file.dashboard_values.rendered]

  depends_on = [
    module.elasticsearch-certificate.cert_status,
  ]
}


resource "keycloak_openid_client" "kibana_client" {
  count = var.enable_keycloak ? 1 : 0 
  realm_id = var.keycloak_realm_id
  client_id = "kibana"
  name = "kibana"
  enabled = true
 
  access_type = "CONFIDENTIAL"
  standard_flow_enabled = true
 
  valid_redirect_uris = [ 
    "https://kibana.${var.namespace}.${var.cluster}.${var.root_zone_name}/oauth/callback"
  ]
 
}

resource "keycloak_openid_audience_protocol_mapper" "audience_mapper" {
  count                    = var.enable_keycloak ? 1 : 0
  realm_id                 = keycloak_openid_client.kibana_client[0].realm_id
  client_id                = keycloak_openid_client.kibana_client[0].id
  name                     = "audience-mapper"

  included_client_audience = keycloak_openid_client.kibana_client[0].client_id 
}

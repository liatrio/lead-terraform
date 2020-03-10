data "template_file" "external_dns_values" {
  template = file("${path.module}/external-dns-values.tpl")

  vars = {
    ns_domain = "${var.cluster}.${var.root_zone_name}"
  }
}

resource "random_string" "keycloak_postgres_password" {
  length = 10
}

module "infrastructure" {
  source                              = "../../modules/lead/infrastructure"
  cluster                             = var.cluster
  namespace                           = var.system_namespace
  enable_opa                          = "false"
  enable_downscaler                   = false
  enable_k8s_spot_termination_handler = false
  opa_failure_policy                  = var.opa_failure_policy
  uptime                              = var.uptime

  external_dns_chart_values = data.template_file.external_dns_values.rendered

  providers = {
    kubernetes = kubernetes
    helm       = helm.system
  }
}

module "toolchain" {
  source                          = "../../modules/lead/toolchain"
  root_zone_name                  = var.root_zone_name
  cluster                         = var.cluster
  cluster_domain                  = "${var.cluster}.${var.root_zone_name}"
  namespace                       = var.toolchain_namespace
  image_whitelist                 = var.image_whitelist
  artifactory_license             = var.artifactory_license
  keycloak_admin_password         = var.keycloak_admin_password
  keycloak_postgres_password      = random_string.keycloak_postgres_password.result
  enable_istio                    = var.enable_istio
  enable_artifactory              = var.enable_artifactory
  enable_gitlab                   = var.enable_gitlab
  enable_keycloak                 = var.enable_keycloak
  enable_mailhog                  = var.enable_mailhog
  enable_sonarqube                = var.enable_sonarqube
  enable_xray                     = var.enable_xray
  enable_grafeas                  = var.enable_grafeas
  enable_harbor                   = var.enable_harbor
  issuer_name                     = module.staging_cluster_issuer.issuer_name
  issuer_kind                     = module.staging_cluster_issuer.issuer_kind
  ingress_controller_type         = var.ingress_controller_type
  ingress_external_traffic_policy = var.ingress_external_traffic_policy
  crd_waiter                      = module.infrastructure.crd_waiter
  grafeas_version                 = var.grafeas_version
  k8s_storage_class               = var.k8s_storage_class
  prometheus_slack_webhook_url    = var.prometheus_slack_webhook_url
  prometheus_slack_channel        = var.prometheus_slack_channel

  harbor_registry_disk_size    = "200Gi"
  harbor_chartmuseum_disk_size = "100Gi"


  smtp_host       = "mailhog"
  smtp_port       = "1025"
  smtp_username   = ""
  smtp_password   = ""
  smtp_from_email = "noreply@liatr.io"

  providers = {
    helm       = helm.toolchain
    kubernetes = kubernetes
  }
}

module "sdm" {
  source                      = "../../modules/lead/sdm"
  root_zone_name              = var.root_zone_name
  cluster                     = var.cluster
  namespace                   = module.toolchain.namespace
  system_namespace            = module.infrastructure.namespace
  sdm_version                 = var.sdm_version
  enable_operators            = var.enable_operators
  product_version             = var.product_version
  slack_bot_token             = var.slack_bot_token
  slack_client_signing_secret = var.slack_client_signing_secret
  workspace_role_name         = "local_workspace_role"
  product_stack               = "product-local"

  product_vars = {
    issuer_type             = var.cert_issuer_type
    issuer_server           = var.cert_issuer_server
    enable_keycloak         = var.enable_keycloak
    builder_images_version  = var.builder_images_version
    jenkins_image_version   = var.jenkins_image_version
    image_repo              = var.image_repo
    ingress_controller_type = var.ingress_controller_type
  }

  providers = {
    kubernetes     = kubernetes
    helm.system    = helm.toolchain
    helm.toolchain = helm.toolchain
  }
}

module "dashboard" {
  source            = "../../modules/lead/dashboard"
  root_zone_name    = var.root_zone_name
  cluster           = var.cluster
  cluster_domain    = "${var.cluster}.${var.root_zone_name}"
  namespace         = module.toolchain.namespace
  dashboard_version = var.dashboard_version
  k8s_storage_class = var.k8s_storage_class
  enabled           = var.enable_dashboard
  local             = true
  enable_keycloak   = var.enable_keycloak
  keycloak_realm_id = module.toolchain.keycloak_realm_id
  crd_waiter        = module.infrastructure.crd_waiter

  providers = {
    kubernetes = kubernetes
    helm       = helm.toolchain
  }
}

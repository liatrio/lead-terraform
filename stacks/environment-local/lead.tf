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
}

module "toolchain" {
  source                  = "../../modules/lead/toolchain"
  root_zone_name          = var.root_zone_name
  cluster                 = var.cluster
  namespace               = var.toolchain_namespace
  image_whitelist         = var.image_whitelist
  artifactory_license     = var.artifactory_license
  keycloak_admin_password = var.keycloak_admin_password
  enable_istio            = var.enable_istio
  enable_artifactory      = var.enable_artifactory
  enable_gitlab           = var.enable_gitlab
  enable_keycloak         = var.enable_keycloak
  enable_harbor           = var.enable_harbor
  issuer_name             = module.staging_cluster_issuer.issuer_name
  issuer_kind             = module.staging_cluster_issuer.issuer_kind
  crd_waiter              = module.infrastructure.crd_waiter
  k8s_storage_class       = var.k8s_storage_class

  harbor_registry_disk_size    = "200Gi"
  harbor_chartmuseum_disk_size = "100Gi"
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
  operators                   = var.lead_sdm_operators
  enable_aws_event_mapper     = var.enable_aws_code_services
  toolchain_image_repo        = var.toolchain_image_repo

  product_vars = {
    issuer_type             = var.cert_issuer_type
    issuer_server           = var.cert_issuer_server
    enable_keycloak         = var.enable_keycloak
    builder_images_version  = var.builder_images_version
    jenkins_image_version   = var.jenkins_image_version
    image_repo              = var.image_repo
    ingress_controller_type = var.ingress_controller_type
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
}

module "lab_partner" {
  source                      = "../../modules/tools/lab-partner"
  enable_lab_partner          = var.enable_lab_partner
  root_zone_name              = var.root_zone_name
  cluster                     = var.cluster
  namespace                   = var.toolchain_namespace
  slack_bot_token             = var.slack_bot_token
  slack_client_signing_secret = var.slack_client_signing_secret
  team_id                     = var.team_id
  lab_partner_version         = var.lab_partner_version
}

module "prometheus-operator" {
  source = "../../modules/tools/prometheus-operator"

  namespace                    = module.toolchain.namespace
  grafana_hostname             = "grafana.${module.toolchain.namespace}.${var.cluster}.${var.root_zone_name}"
  prometheus_slack_webhook_url = var.prometheus_slack_webhook_url
  prometheus_slack_channel     = var.prometheus_slack_channel
}

module "sonarqube" {
  source = "../../modules/tools/sonarqube"

  enable_sonarqube = var.enable_sonarqube
  namespace        = module.toolchain.namespace
}

module "kube_resource_report" {
  source = "../../modules/tools/kube-resource-report"

  namespace      = module.toolchain.namespace
  cluster        = var.cluster
  root_zone_name = var.root_zone_name
}

module "rode" {
  source = "../../modules/tools/rode"

  namespace          = var.toolchain_namespace
  ingress_domain     = "${var.cluster}.${var.root_zone_name}"
  localstack_enabled = var.localstack_enabled
}

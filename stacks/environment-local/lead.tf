data "template_file" "external_dns_values" {
  template = file("${path.module}/external-dns-values.tpl")

  vars = {
    ns_domain = "${var.cluster}.${var.root_zone_name}"
  }
}

module "infrastructure" {
  source             = "../../modules/lead/infrastructure"
  root_zone_name     = var.root_zone_name
  cluster            = var.cluster
  namespace          = var.system_namespace
  enable_opa         = "false"
  opa_failure_policy = var.opa_failure_policy
  issuer_type        = "selfSigned"

  external_dns_chart_values = data.template_file.external_dns_values.rendered

  providers = {
    helm = helm.system
  }
}

module "toolchain" {
  source                          = "../../modules/lead/toolchain"
  root_zone_name                  = var.root_zone_name
  cluster                         = var.cluster
  namespace                       = var.toolchain_namespace
  image_whitelist                 = var.image_whitelist
  artifactory_license             = var.artifactory_license
  keycloak_admin_password         = var.keycloak_admin_password
  enable_artifactory              = var.enable_artifactory
  enable_gitlab                   = var.enable_gitlab
  enable_keycloak                 = var.enable_keycloak
  enable_mailhog                  = var.enable_mailhog
  enable_sonarqube                = var.enable_sonarqube
  enable_xray                     = var.enable_xray
  issuer_type                     = "selfSigned"
  ingress_controller_type         = var.ingress_controller_type
  ingress_external_traffic_policy = var.ingress_external_traffic_policy
  crd_waiter                      = module.infrastructure.crd_waiter

  providers = {
    helm = helm.toolchain
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

  providers = {
    helm.system    = helm.toolchain
    helm.toolchain = helm.toolchain
  }
}

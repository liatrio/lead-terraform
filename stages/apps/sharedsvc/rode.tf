data "vault_generic_secret" "rode" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/rode"
}

locals {
  rode_oidc_client_id = "rode"
  rode_hostname       = "rode.${var.cluster_domain}"
  ui_hostname         = "rode-dashboard.${var.cluster_domain}"
}

module "rode_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = "rode"
}

module "rode" {
  source = "../../../modules/tools/rode"

  namespace                = module.rode_namespace.name
  rode_service_account_arn = var.rode_service_account_arn

  rode_ui_enabled       = true
  ingress_class         = module.nginx_external.ingress_class
  ui_ingress_hostname   = local.ui_hostname
  rode_ingress_hostname = local.rode_hostname

  oidc_issuer_url           = local.keycloak_issuer_uri
  oidc_issuer_client_id     = local.rode_oidc_client_id
  oidc_issuer_client_secret = data.vault_generic_secret.rode.data["oidc_issuer_client_secret"]

  grafeas_elasticsearch_username = data.vault_generic_secret.rode.data["grafeas_elasticsearch_username"]
  grafeas_elasticsearch_password = data.vault_generic_secret.rode.data["grafeas_elasticsearch_password"]
}

data "vault_generic_secret" "rode" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/rode"
}

locals {
  rode_oidc_client_id              = "rode"
  rode_hostname                    = "rode.${var.cluster_domain}"
  rode_grpc_hostname               = "rode-grpc.${var.cluster_domain}"
  ui_hostname                      = "rode-dashboard.${var.cluster_domain}"
  build_collector_hostname         = "build-collector.${var.cluster_domain}"
  image_scanner_collector_hostname = "image-scanner-collector.${var.cluster_domain}"
  build_collector_grpc_hostname    = "build-collector-grpc.${var.cluster_domain}"
  tfsec_collector_hostname         = "tfsec-collector.${var.cluster_domain}"
}

module "rode_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = "rode"
  annotations = {
    "downscaler/exclude" = "true"
  }
}

resource "kubernetes_secret" "image_scanner_docker_config" {
  metadata {
    name      = "image-scanner-collector-docker-config"
    namespace = module.rode_namespace.name
  }

  # Additional entries under auths can be created to support other registries
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "azuredemoshared.azurecr.io" = {
          "username" = "azuredemoshared"
          "password" = data.vault_generic_secret.rode.data["acr_image_pull_secret"]
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

module "rode" {
  source = "../../../modules/tools/rode"

  namespace = module.rode_namespace.name

  ingress_class                    = module.nginx_external.ingress_class
  ui_ingress_hostname              = local.ui_hostname
  rode_ui_enabled                  = true
  rode_ingress_hostname            = local.rode_hostname
  rode_grpc_ingress_hostname       = local.rode_grpc_hostname
  build_collector_hostname         = local.build_collector_hostname
  build_collector_grpc_hostname    = local.build_collector_grpc_hostname
  tfsec_collector_hostname         = local.tfsec_collector_hostname
  image_scanner_collector_hostname = local.image_scanner_collector_hostname
  docker_config_secret             = kubernetes_secret.image_scanner_docker_config.metadata.0.name
  harbor_url                       = "https://${local.harbor_hostname}"

  oidc_issuer_url    = local.keycloak_issuer_uri
  oidc_token_url     = local.keycloak_token_uri
  oidc_client_id     = local.rode_oidc_client_id
  oidc_client_secret = data.vault_generic_secret.rode.data["oidc_client_secret"]

  collector_client_id     = "rode-collector"
  collector_client_secret = data.vault_generic_secret.rode.data["collector_client_secret"]

  grafeas_elasticsearch_username = data.vault_generic_secret.rode.data["grafeas_elasticsearch_username"]
  grafeas_elasticsearch_password = data.vault_generic_secret.rode.data["grafeas_elasticsearch_password"]
}

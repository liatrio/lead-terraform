data "vault_generic_secret" "sonarqube" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/sonarqube"
}

locals {
  sonar_keycloak_client_id = "sonarqube"
  sonarqube_hostname       = "sonarqube.${var.cluster_domain}"
}


module "sonarqube_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = "sonarqube"
}

module "sonarqube" {
  source = "../../../modules/tools/sonarqube"

  admin_password    = data.vault_generic_secret.sonarqube.data["admin"]
  postgres_password = data.vault_generic_secret.sonarqube.data["postgres"]
  namespace         = module.sonarqube_namespace.name
  ingress_enabled   = true
  ingress_hostname  = local.sonarqube_hostname
  ingress_annotations = {
    "kubernetes.io/ingress.class" : module.nginx_external.ingress_class
  }
  enable_keycloak        = true
  keycloak_issuer_uri    = local.keycloak_issuer_uri
  keycloak_client_id     = local.sonar_keycloak_client_id
  keycloak_client_secret = data.vault_generic_secret.sonarqube.data["keycloak_client_secret"]
}


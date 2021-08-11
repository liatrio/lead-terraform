data "vault_generic_secret" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0
  path  = "lead/aws/${data.aws_caller_identity.current.account_id}/sonarqube"
}

module "sonarqube" {
  source = "../../../modules/tools/sonarqube"
  count  = var.enable_sonarqube ? 1 : 0

  admin_password    = data.vault_generic_secret.sonarqube[0].data["admin_password"]
  postgres_password = data.vault_generic_secret.sonarqube[0].data["postgres_password"]
  namespace         = var.toolchain_namespace
  ingress_enabled   = true
  ingress_hostname  = "sonarqube.toolchain.${var.cluster_name}.${var.root_zone_name}"
  ingress_annotations = {
    "kubernetes.io/ingress.class" : "toolchain-nginx"
    "ingress.kubernetes.io/ssl-redirect" : "true"
  }
}


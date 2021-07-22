data "vault_generic_secret" "sonarqube" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/sonarqube"
}

module "sonarqube" {
  source = "../../../modules/tools/sonarqube"

  enable_sonarqube = var.enable_sonarqube
  admin_password   = data.vault_generic_secret.sonarqube.data["admin_password"]
  namespace        = var.toolchain_namespace
  ingress_enabled  = true
  ingress_hostname = "sonarqube.toolchain.${var.cluster_name}.${var.root_zone_name}"
  ingress_annotations = {
    "kubernetes.io/ingress.class" : "toolchain-nginx"
    "ingress.kubernetes.io/ssl-redirect" : "true"
  }
}


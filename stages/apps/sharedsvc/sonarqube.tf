data "vault_generic_secret" "sonarqube" {
  path = "lead/aws/265560927720/sonarqube"
}

module "sonarqube_namespace" {
  source      = "../../../modules/common/namespace"
  namespace   = "sonarqube"
}

module "sonarqube" {
  source = "../../../modules/tools/sonarqube"

  admin_password    = data.vault_generic_secret.sonarqube.data["admin"]
  postgres_password = data.vault_generic_secret.sonarqube.data["postgres"]
  namespace         = module.sonarqube_namespace.name
  ingress_enabled   = true
  ingress_hostname  = "sonarqube.${var.cluster_domain}"
  ingress_annotations = {
    "kubernetes.io/ingress.class" : "nginx-external"
  }
}


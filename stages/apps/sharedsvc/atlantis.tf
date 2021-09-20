module "atlantis_namespace" {
  source      = "../../../modules/common/namespace"
  namespace   = "atlantis"
  annotations = {
    name    = "atlantis"
    cluster = var.eks_cluster_id
  }
}

data "vault_generic_secret" "github" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/github"
}

data "vault_generic_secret" "atlantis" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/atlantis"
}

module "atlantis" {
  source = "../../../modules/tools/atlantis"

  github_username       = data.vault_generic_secret.github.data["username"]
  github_token          = data.vault_generic_secret.github.data["token"]
  github_webhook_secret = data.vault_generic_secret.atlantis.data["webhook_secret"]
  namespace             = module.atlantis_namespace.name
  role_arn              = var.atlantis_service_account_arn
  ingress_hostname      = "atlantis.${var.cluster_domain}"
  ingress_annotations   = {
    "kubernetes.io/ingress.class": module.nginx_external.ingress_class
    "nginx.ingress.kubernetes.io/configuration-snippet": <<EOF
location /apply/lock {
  deny all;
}
EOF
  }
}

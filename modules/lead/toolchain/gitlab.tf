data "helm_repository" "gitlab" {
  name = "gitlab"
  url  = "https://charts.gitlab.io/"
}

data "template_file" "gitlab_values" {
  template = file("${path.module}/gitlab-values.tpl")

  vars = {
    ssl_redirect     = var.root_zone_name == "localhost" ? false : true
    ingress_hostname = "gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    gitlab_admin_password_secret = kubernetes_secret.gitlab_admin.metadata[0].name
    gitlab_admin_password_key = "password"
    gitlab_db_password_secret = kubernetes_secret.gitlab_db.metadata[0].name
    gitlab_db_password_key = "password"
    smtp_host = "mailhog"
    smtp_port = "1025"
    smtp_from_email = "noreply@gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    smtp_from_name = "Gitlab - ${module.toolchain_namespace.name}"
    smtp_replyto = "noreply@gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    keycloak_gitlab_saml_key_fingerprint = tls_private_key.keycloak_gitlab_saml_key.public_key_fingerprint_md5
  }
}

resource "random_string" "gitlab_admin_password" {
  length  = 10
  special = false
}

resource "random_string" "gitlab_db_password" {
  length  = 10
  special = false
}

resource "kubernetes_secret" "gitlab_admin" {
  metadata {
    name      = "gitlab-admin-credential"
    namespace = module.toolchain_namespace.name
  }
  type = "Opaque"

  data = {
    username = "admin"
    password = random_string.gitlab_admin_password.result
  }
}

resource "kubernetes_secret" "gitlab_db" {
  metadata {
    name      = "gitlab-db-credential"
    namespace = module.toolchain_namespace.name
  }
  type = "Opaque"

  data = {
    password = random_string.gitlab_db_password.result
  }
}

resource "helm_release" "gitlab" {
  count      = var.enable_gitlab ? 1 : 0 
  repository = data.helm_repository.gitlab.metadata[0].name
  name       = "gitlab"
  namespace  = module.toolchain_namespace.name
  chart      = "gitlab"
  version    = "2.0.3"
  timeout    = 1200

  values = [data.template_file.gitlab_values.rendered]
}


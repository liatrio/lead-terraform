data "helm_repository" "gitlab" {
  name = "gitlab"
  url  = "https://charts.gitlab.io/"
}

data "template_file" "gitlab_values" {
  template = file("${path.module}/gitlab-values.tpl")

  vars = {
    ingress_hostname = "gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    gitlab_admin_password_secret = kubernetes_secret.gitlab_admin.metadata[0].name
    gitlab_admin_password_key = "password"
    gitlab_db_password_secret = kubernetes_secret.gitlab_db.metadata[0].name
    gitlab_db_password_key = "password"
    smtp_host = ""
    smtp_port = "587"
    smtp_username = ""
    smtp_secret_name = ""
    smtp_secret_key = ""
    smtp_from_email = ""
    smtp_from_name = ""
    smtp_replyto = ""
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
  repository = data.helm_repository.gitlab.metadata[0].name
  name       = "gitlab"
  namespace  = module.toolchain_namespace.name
  chart      = "gitlab"
  version    = "2.0.3"
  timeout    = 1200

  values = [data.template_file.gitlab_values.rendered]
}


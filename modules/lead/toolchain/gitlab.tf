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

###############################################################################
# Gitlab<>Jenkins Integration https://docs.gitlab.com/ce/integration/jenkins.html
# Old way of using webhooks is deprecated, but might be only option.  Still unclear.

# psql provider
  # ARGHHH! https://github.com/terraform-providers/terraform-provider-postgresql/issues/2#issuecomment-369341707
  # Core issue: https://github.com/hashicorp/terraform/issues/4149

# psql query to create/get PAT for root user, no way to do this with tf/api

# provider "gitlab" {
#   token = "${var.gitlab_token}" # root user PAT
# }

# resource "random_string" "gitlab_jenkins_password" {
#   length  = 10
#   special = false
# }

# resource "gitlab_user" "jenkins" {
#   name             = "Jenkins"
#   username         = "jenkins"
#   password         = random_string.gitlab_jenkins_password.result
#   email            = "gitlab@user.create"
#   is_admin         = true
#   projects_limit   = 4
#   can_create_group = false
#   is_external      = false
# }
# 

# psql query to create/get PAT for jenkins user with scope 'api', no way to do this with tf/api

# reference is https://<jenkins_url>/configuration-as-code/reference
# set gitlab url and api token in jenkins global configuration `jenkins-values.tpl:JCasC

# resource "gitlab_project" "??"

# psql query to enable jenkins integration for project, no way to do this with tf/api


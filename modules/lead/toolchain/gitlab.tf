data "helm_repository" "gitlab" {
  count = var.enable_gitlab ? 1 : 0 
  name  = "gitlab"
  url   = "https://charts.gitlab.io/"
}

data "template_file" "gitlab_values" {
  count    = var.enable_gitlab ? 1 : 0 
  template = file("${path.module}/gitlab-values.tpl")

  vars = {
    ssl_redirect     = var.root_zone_name == "localhost" ? false : true
    ingress_hostname = "gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    smtp_host        = "mailhog"
    smtp_port        = "1025"
    smtp_from_email  = "noreply@gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    smtp_from_name   = "Gitlab - ${module.toolchain_namespace.name}"
    smtp_replyto     = "noreply@gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  }
}

data "external" "keycloak_realm_certificate" {
  depends_on = [helm_release.keycloak, helm_release.keycloak_realm]
  count      = var.enable_gitlab && var.enable_keycloak ? 1 : 0 
  program    = ["sh", "${path.module}/scripts/get_keycloak_realm_certificate.sh", "${local.protocol}://keycloak.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}/auth/realms/${module.toolchain_namespace.name}/protocol/saml/descriptor"]
}

resource "kubernetes_secret" "gitlab_keycloak_saml_config" {
  count = var.enable_gitlab && var.enable_keycloak ? 1 : 0 
  metadata {
    name      = "gitlab-keycloak-saml"
    namespace = module.toolchain_namespace.name
  }
  type = "Opaque"

  # The `idp_cert` needs to the be realm certificate, not the realm client certificate as all the docs say!?!?!
  # All the SAMLResposnes returned by Keycloak use the realm certificate for some unknown reason
  data = {
    provider = <<EOF
name: 'saml'
label: 'Keycloak'
groups_attribute: 'roles'
external_groups: ['ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}:external']
args:
  assertion_consumer_service_url: '${local.protocol}://ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}/users/auth/saml/callback'
  idp_cert: '${data.external.keycloak_realm_certificate[0].result.certifcate}'
  idp_sso_target_url: '${local.protocol}://keycloak.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}/auth/realms/${module.toolchain_namespace.name}/protocol/saml/clients/ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}'
  issuer: 'ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}'
  name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistant'
  attribute_statements:
    first_name: ['first_name']
    last_name: ['last_name']
    name: ['username']
    username: ['username']
    email: ['email']
EOF
  }
}

resource "helm_release" "gitlab" {
  count      = var.enable_gitlab ? 1 : 0 
  depends_on = [kubernetes_secret.gitlab_keycloak_saml_config]
  repository = data.helm_repository.gitlab[0].metadata[0].name
  name       = "gitlab"
  namespace  = module.toolchain_namespace.name
  chart      = "gitlab"
  version    = "2.0.3"
  timeout    = 1200

  values = [data.template_file.gitlab_values[0].rendered]
}

resource "keycloak_saml_client" "gitlab_saml_client" {
  count                   = var.enable_gitlab && var.enable_keycloak ? 1 : 0
  depends_on              = [keycloak_realm.realm]
  realm_id                = keycloak_realm.realm[0].id
  client_id               = "ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  name                    = "Gitlab"

  sign_documents            = true
  sign_assertions           = true
  include_authn_statement   = true
  full_scope_allowed        = true
  client_signature_required = true

  name_id_format              = "persistent"
  root_url                    = "${local.protocol}://ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  base_url                    = "/"
  valid_redirect_uris         = ["${local.protocol}://ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}/users/auth/saml/callback"]
  idp_initiated_sso_url_name  = "ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"

  master_saml_processing_url      = "${local.protocol}://ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}/users/auth/saml/callback"
  assertion_consumer_post_url     = "${local.protocol}://ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}/users/auth/saml/callback"
  assertion_consumer_redirect_url = "${local.protocol}://ui.gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}/users/auth/saml/callback"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_user_property_mapper_roles" {
  count                      = var.enable_gitlab && var.enable_keycloak ? 1 : 0
  realm_id                   = keycloak_realm.realm[0].id
  client_id                  = keycloak_saml_client.gitlab_saml_client[0].id
  name                       = "roles"

  user_property              = "roles"
  saml_attribute_name        = "roles"
  saml_attribute_name_format = "Basic"
  friendly_name              = "Roles"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_user_property_mapper_last_name" {
  count                      = var.enable_gitlab && var.enable_keycloak ? 1 : 0
  realm_id                   = keycloak_realm.realm[0].id
  client_id                  = keycloak_saml_client.gitlab_saml_client[0].id
  name                       = "last_name"

  user_property              = "lastName"
  saml_attribute_name        = "last_name"
  saml_attribute_name_format = "Basic"
  friendly_name              = "Last Name"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_user_property_mapper_first_name" {
  count                      = var.enable_gitlab && var.enable_keycloak ? 1 : 0
  realm_id                   = keycloak_realm.realm[0].id
  client_id                  = keycloak_saml_client.gitlab_saml_client[0].id
  name                       = "first_name"

  user_property              = "firstName"
  saml_attribute_name        = "first_name"
  saml_attribute_name_format = "Basic"
  friendly_name              = "First Name"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_user_property_mapper_email" {
  count                      = var.enable_gitlab && var.enable_keycloak ? 1 : 0
  realm_id                   = keycloak_realm.realm[0].id
  client_id                  = keycloak_saml_client.gitlab_saml_client[0].id
  name                       = "email"

  user_property              = "email"
  saml_attribute_name        = "email"
  saml_attribute_name_format = "Basic"
  friendly_name              = "Email"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_user_property_mapper_username" {
  count                      = var.enable_gitlab && var.enable_keycloak ? 1 : 0
  realm_id                   = keycloak_realm.realm[0].id
  client_id                  = keycloak_saml_client.gitlab_saml_client[0].id
  name                       = "username"

  user_property              = "username"
  saml_attribute_name        = "username"
  saml_attribute_name_format = "Basic"
  friendly_name              = "Username"
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

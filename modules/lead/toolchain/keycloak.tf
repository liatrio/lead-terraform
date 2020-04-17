locals {
  keycloak_hostname = "keycloak.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
}

data "template_file" "keycloak_values" {
  template = file("${path.module}/keycloak-values.tpl")

  vars = {
    ssl_redirect     = var.root_zone_name == "localhost" ? false : true
    cluster_domain   = "${var.cluster}.${var.root_zone_name}"
    ingress_hostname = "keycloak.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  }
}

resource "kubernetes_secret" "keycloak_admin" {
  metadata {
    name      = "keycloak-admin-credential"
    namespace = module.toolchain_namespace.name
  }
  type = "Opaque"

  data = {
    username = "keycloak"
    password = var.keycloak_admin_password
  }
}

resource "helm_release" "keycloak" {
  count      = var.enable_keycloak ? 1 : 0
  depends_on = [
    helm_release.mailhog
  ]
  repository = data.helm_repository.codecentric.metadata[0].name
  name       = "keycloak"
  namespace  = module.toolchain_namespace.name
  chart      = "keycloak"
  version    = "5.0.1"
  timeout    = 1200

  values = [
    data.template_file.keycloak_values.rendered
  ]

  set_sensitive {
    name  = "postgresql.postgresqlPassword"
    value = var.keycloak_postgres_password
  }
}


# while using client credentials is preferred, it would require initial client creation using the
# old realm import method, so just use password based setup since that is known prior to keycloak
# resource
provider "keycloak" {
  client_id      = "admin-cli"
  username       = "keycloak"
  password       = var.keycloak_admin_password
  url            = "${local.protocol}://${local.keycloak_hostname}"
  initial_login  = false
  client_timeout = 15
}

# Give Keycloak API a chance to become responsive
resource "null_resource" "keycloak_realm_delay" {
  count      = var.enable_keycloak ? 1 : 0
  depends_on = [
    helm_release.keycloak
  ]

  provisioner "local-exec" {
    command = "sleep 15"
  }
}

resource "keycloak_realm" "realm" {
  count        = var.enable_keycloak ? 1 : 0
  depends_on   = [
    helm_release.keycloak,
    null_resource.keycloak_realm_delay
  ]
  realm        = module.toolchain_namespace.name
  enabled      = true
  display_name = title(module.toolchain_namespace.name)

  registration_allowed           = false
  registration_email_as_username = false
  reset_password_allowed         = true
  remember_me                    = true
  verify_email                   = true
  login_with_email_allowed       = true
  duplicate_emails_allowed       = false

  smtp_server {
    host              = var.smtp_host
    port              = var.smtp_port
    starttls          = true
    ssl               = false
    from              = var.smtp_from_email
    from_display_name = "Keycloak - ${var.root_zone_name} ${title(var.cluster)} ${title(var.namespace)}"

    dynamic "auth" {
      for_each = var.smtp_username == "" || var.smtp_password == "" ? [] : [1]

      content {
        username = var.smtp_username
        password = var.smtp_password
      }
    }
  }
}

resource "keycloak_oidc_google_identity_provider" "google" {
  count = var.enable_keycloak && var.enable_google_login ? 1 : 0

  realm         = keycloak_realm.realm[0].id
  client_id     = var.google_identity_provider_client_id
  client_secret = var.google_identity_provider_client_secret
  trust_email   = true
  hosted_domain = "liatrio.com"
}

resource "keycloak_user" "test_user" {
  count = var.enable_keycloak && var.enable_test_user ? 1 : 0

  realm_id = keycloak_realm.realm[0].id
  username = "casey"

  initial_password {
    value     = var.test_user_password
    temporary = false
  }

  email_verified = true
}

resource "kubernetes_secret" "keycloak_toolchain_realm" {
  count      = var.enable_keycloak ? 1 : 0
  depends_on = [
    keycloak_realm.realm
  ]

  metadata {
    name      = "keycloak-toolchain-realm"
    namespace = module.toolchain_namespace.name
  }
  type = "Opaque"

  data = {
    id = keycloak_realm.realm[0].id
  }
}

resource "kubernetes_secret" "keycloak_toolchain_realm_disabled" {
  count = var.enable_keycloak ? 0 : 1

  metadata {
    name      = "keycloak-toolchain-realm"
    namespace = module.toolchain_namespace.name
  }
  type = "Opaque"

  data = {
    id = ""
  }
}

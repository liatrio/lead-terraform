resource "kubernetes_secret" "keycloak_admin" {
  metadata {
    name      = "keycloak-admin-credential"
    namespace = var.namespace
  }
  type = "Opaque"

  data = {
    username = "keycloak"
    password = var.keycloak_admin_password
  }
}

resource "helm_release" "keycloak" {
  count      = var.enable_keycloak ? 1 : 0
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

# Give Keycloak API a chance to become responsive
resource "null_resource" "keycloak_realm_delay" {
  count      = var.enable_keycloak ? 1 : 0

  provisioner "local-exec" {
    command = "sleep 15"
  }
}

resource "keycloak_realm" "realm" {
  count        = var.enable_keycloak ? 1 : 0
  depends_on   = [
    null_resource.keycloak_realm_delay
  ]
  realm        = var.namespace
  enabled      = true
  display_name = title(var.namespace)

  registration_allowed           = false
  registration_email_as_username = false
  reset_password_allowed         = true
  remember_me                    = true
  verify_email                   = true
  login_with_email_allowed       = true
  duplicate_emails_allowed       = false
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
    namespace = var.namespace
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
    namespace = var.namespace
  }
  type = "Opaque"

  data = {
    id = ""
  }
}

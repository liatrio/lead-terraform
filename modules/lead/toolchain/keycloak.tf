data "template_file" "keycloak_values" {
  template = file("${path.module}/keycloak-values.tpl")

  vars = {
    cluster_domain   = "${var.cluster}.${var.root_zone_name}"
    ingress_hostname = "keycloak.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  }
}

resource "random_string" "keycloak_admin_password" {
  length  = 10
  special = false
}

resource "kubernetes_secret" "keycloak_admin" {
  metadata {
    name      = "keycloak-admin-credential"
    namespace = module.toolchain_namespace.name
  }
  type = "Opaque"

  data = {
    username = "keycloak"
    password = random_string.keycloak_admin_password.result
  }
}

resource "helm_release" "keycloak" {
  depends_on = [helm_release.mailhog]
  repository = data.helm_repository.codecentric.metadata[0].name
  name       = "keycloak"
  namespace  = module.toolchain_namespace.name
  chart      = "keycloak"
  version    = "5.0.1"
  timeout    = 1200

  values = [data.template_file.keycloak_values.rendered]
}


# while using client credentials is preferred, it would require initial client creation using the 
# old realm import method, so just use password based setup since that is known prior to keycloak 
# resource creation
provider "keycloak" {
  client_id = "admin-cli"
  username  = "keycloak"
  password  = random_string.keycloak_admin_password.result
  url       = "https://keycloak.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
}

resource "keycloak_realm" "realm" {
  depends_on    = [helm_release.keycloak]
  realm         = module.toolchain_namespace.name
  enabled       = true
  display_name  = title(module.toolchain_namespace.name)

  registration_allowed            = true
  registration_email_as_username  = true
  reset_password_allowed          = true
  remember_me                     = true
  verify_email                    = true
  login_with_email_allowed        = true
  duplicate_emails_allowed        = false

  smtp_server {
    host              = "mailhog"
    port              = "1025"
    from              = "keycloak@${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    from_display_name = "Keycloak - ${title(module.toolchain_namespace.name)}"
  }
}

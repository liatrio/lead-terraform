
data "template_file" "keycloak_values" {
  template = file("${path.module}/keycloak-values.tpl")

  vars = {
    cluster_domain   = "${var.cluster}.${var.root_zone_name}"
    ingress_hostname = "keycloak.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    admin_username   = kubernetes_secret.keycloak_admin.data.username
    admin_password   = random_string.keycloak_admin_password.result
    realm_name       = module.toolchain_namespace.name
    realm_secret     = kubernetes_secret.keycloak_realm.metadata[0].name
  }
}

data "template_file" "keycloak_realm" {
  template = file("${path.module}/keycloak_realm.json")

  vars = {
    toolchain_domain = "${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    keycloak_gitlab_saml_cert = replace(replace(replace(tls_self_signed_cert.keycloak_gitlab_saml_cert.cert_pem, "-----BEGIN CERTIFICATE-----", ""), "-----END CERTIFICATE-----", ""), "\n", "")
    keycloak_gitlab_saml_key = replace(replace(replace(tls_private_key.keycloak_gitlab_saml_key.private_key_pem, "-----BEGIN RSA PRIVATE KEY-----", ""), "-----END RSA PRIVATE KEY-----", ""), "\n", "")
    smtp_json = <<EOT
{
  "host": "mailhog",
  "port": "1025",
  "from": "keycloak@${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}",
  "fromDisplayName": "Keycloak - ${module.toolchain_namespace.name}",
  "auth": "false"
}
EOT
  }
}

resource "tls_private_key" "keycloak_gitlab_saml_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "keycloak_gitlab_saml_cert" {
  key_algorithm   = "${tls_private_key.keycloak_gitlab_saml_key.algorithm}"
  private_key_pem = "${tls_private_key.keycloak_gitlab_saml_key.private_key_pem}"

  # Certificate expires after ~10 years.
  validity_period_hours = 100000

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
      "key_encipherment",
      "digital_signature",
      "server_auth",
  ]

  subject {
      common_name  = "keycloak-saml-gitlab.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
      organization = "${var.cluster}.${var.root_zone_name}"
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

resource "kubernetes_secret" "keycloak_realm" {
  metadata {
    name      = "keycloak-realm"
    namespace = module.toolchain_namespace.name
  }
  type = "Opaque"

  data = {
    "toolchain_realm.json" = data.template_file.keycloak_realm.rendered
  }

  lifecycle {
    # once a realm has been imported, the only two options for future imports are
    # IGNORE_EXISTING and OVERWRITE_EXISTING, and we don't want to ever overwrite a 
    # realm since users would be lost, therefore don't apply any changes to the realm
    # that might give the impression that the realm would be updated.
    # we may want to look into using `kcadm.sh update realms` which will merge new
    # attribute values with existing values, but `kcadm.sh` must be executed after startup
    # and this helm chart doesn't expose a mechanism to run post-startup commands.
    ignore_changes = [data]
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


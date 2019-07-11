
data "helm_repository" "codecentric" {
  name = "codecentric"
  url  = "https://codecentric.github.io/helm-charts"
}

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
    # don't use periods in name because tf .12 currently breaks on referencing map key values
    # with periods in `lifecycle.ignore_changes`
    "toolchain_realm.json" = file("${path.module}/keycloak_realm.json")
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
  repository = data.helm_repository.codecentric.metadata[0].name
  name       = "keycloak"
  namespace  = module.toolchain_namespace.name
  chart      = "keycloak"
  version    = "5.0.1"
  timeout    = 1200

  values = [data.template_file.keycloak_values.rendered]
}


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

resource "random_string" "artifactory_xray_db_password" {
  length  = 10
  special = false
}

resource "random_string" "artifactory_xray_mongo_db_password" {
  length  = 10
  special = false
}

data "template_file" "xray_values" {
  template = file("${path.module}/xray-values.tpl")

  vars = {
    ingress_hostname = "artifactory.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  }
}

resource "helm_release" "xray" {
  count      = var.enable_xray ? 1 : 0
  repository = data.helm_repository.jfrog.metadata[0].name
  name       = "xray"
  namespace  = module.toolchain_namespace.name
  chart      = "xray"
  version    = "0.12.10"
  timeout    = 1200

  // set_sensitive {
  //   name  = "xray.license.licenseKey"
  //   value = "${var.artifactory_xray_license}"
  // }
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set_sensitive {
    name  = "mongodb.mongodbPassword"
    value = random_string.artifactory_xray_mongo_db_password.result
  }

  set_sensitive {
    name  = "postgresql.postgresPassword"
    value = random_string.artifactory_xray_db_password.result
  }

  values = [data.template_file.xray_values.rendered]

}

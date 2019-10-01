resource "random_string" "artifactory_xray_db_password" {
  length  = 10
  special = false
}

resource "random_string" "artifactory_xray_mongo_db_password" {
  length  = 10
  special = false
}

resource "random_string" "artifactory_xray_mongo_db_root_password" {
  length  = 10
  special = false
}

resource "random_string" "artifactory_xray_rabbitmq_password" {
  length  = 10
  special = false
}

resource "random_id" "artifactory_xray_master_key" {
  byte_length  = 32 
}

data "template_file" "xray_values" {
  template = file("${path.module}/xray-values.tpl")

  vars = {
    ingress_hostname = "xray.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  }
}

resource "helm_release" "xray" {
  count      = var.enable_xray ? 1 : 0
  repository = data.helm_repository.jfrog.metadata[0].name
  name       = "xray"
  namespace  = module.toolchain_namespace.name
  chart      = "xray"
  version    = "1.1.0"
  timeout    = 1200

  // set_sensitive {
  //   name  = "xray.license.licenseKey"
  //   value = "${var.artifactory_xray_license}"
  // }

  set_sensitive {
    name  = "common.masterKey"
    value = random_id.artifactory_xray_master_key.hex
  }

  set_sensitive {
    name  = "mongodb.mongodbPassword"
    value = random_string.artifactory_xray_mongo_db_password.result
  }

  set_sensitive {
    name  = "mongodb.mongodbRootPassword"
    value = random_string.artifactory_xray_mongo_db_root_password.result
  }

  set_sensitive {
    name  = "postgresql.postgresPassword"
    value = random_string.artifactory_xray_db_password.result
  }

  set_sensitive {
    name  = "rabbitmq.rabbitmqPassword"
    value = random_string.artifactory_xray_rabbitmq_password.result
  }

  values = [data.template_file.xray_values.rendered]

}

resource "random_string" "harbor_admin_password" {
  length  = 10
  special = false
}

resource "random_string" "harbor_db_password" {
  length  = 10
  special = false
}

resource "random_string" "harbor_secret_key" {
  length  = 16
  special = false
}

resource "random_string" "harbor_core_secret" {
  length  = 16
  special = false
}

resource "random_string" "harbor_jobservice_secret" {
  length  = 16
  special = false
}

resource "random_string" "harbor_registry_secret" {
  length  = 16
  special = false
}

data "helm_repository" "harbor" {
  name = "harbor"
  url = "https://helm.goharbor.io"
}

data "template_file" "harbor_values" {
  template = file("${path.module}/harbor-values.tpl")

  vars = {
    harbor_ingress_hostname = "harbor.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
    notary_ingress_hostname = "notary.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"

    ssl_redirect = true

    registry_pvc_size = "200Gi"
    chartmuseum_pvc_size = "100Gi"
    jobservice_pvc_size = "10Gi"
    database_pvc_size = "10Gi"
    redis_pvc_size = "10Gi"
  }
}

resource "helm_release" "harbor" {
  count = var.enable_harbor ? 1 : 0
  repository = data.helm_repository.harbor.metadata[0].name
  name = "harbor"
  namespace = module.toolchain_namespace.name
  chart = "harbor"
  version = "1.2.3"

  values = [data.template_file.harbor_values.rendered]

  set_sensitive {
    name = "harborAdminPassword"
    value = random_string.harbor_admin_password.result
  }

  set_sensitive {
    name = "secretKey"
    value = random_string.harbor_secret_key.result
  }

  set_sensitive {
    name = "core.secret"
    value = random_string.harbor_core_secret.result
  }

  set_sensitive {
    name = "jobservice.secret"
    value = random_string.harbor_jobservice_secret.result
  }

  set_sensitive {
    name = "registry.secret"
    value = random_string.harbor_registry_secret.result
  }

  set_sensitive {
    name = "database.internal.password"
    value = random_string.harbor_db_password.result
  }
}

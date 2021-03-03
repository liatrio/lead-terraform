locals {
  harbor_hostname = "harbor.${var.namespace}.${var.cluster}.${var.root_zone_name}"
  notary_hostname = "notary.${var.namespace}.${var.cluster}.${var.root_zone_name}"
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

resource "helm_release" "harbor_volumes" {
  count     = var.enable ? 1 : 0
  chart     = "${path.module}/charts/harbor-volumes"
  name      = "harbor-volumes"
  namespace = var.namespace
  wait      = true

  set {
    name  = "components.registry.size"
    value = var.harbor_registry_disk_size
  }

  set {
    name  = "components.registry.protectPvcResource"
    value = var.protect_pvc_resources
  }

  set {
    name  = "components.chartmuseum.size"
    value = var.harbor_chartmuseum_disk_size
  }

  set {
    name  = "components.chartmuseum.protectPvcResource"
    value = var.protect_pvc_resources
  }

  set {
    name = "components.database.size"
    value = var.harbor_database_disk_size
  }

  set {
    name = "components.database.protectPvcResource"
    value = var.protect_pvc_resources
  }

  set {
    name  = "storageClassName"
    value = var.k8s_storage_class
  }
}

resource "helm_release" "harbor_certificates" {
  count     = var.enable ? 1 : 0
  chart     = "${path.module}/charts/harbor-certificates"
  name      = "harbor-certificates"
  namespace = var.namespace
  wait      = true

  set {
    name  = "harbor.hostname"
    value = local.harbor_hostname
  }

  set {
    name  = "notary.hostname"
    value = local.notary_hostname
  }

  set {
    name  = "harbor.secret"
    value = "harbor-tls"
  }

  set {
    name  = "notary.secret"
    value = "notary-tls"
  }

  set {
    name  = "issuer.kind"
    value = var.issuer_kind
  }

  set {
    name  = "issuer.name"
    value = var.issuer_name
  }
}

data "template_file" "harbor_values" {
  template = file("${path.module}/harbor-values.tpl")

  vars = {
    harbor_ingress_hostname = local.harbor_hostname
    notary_ingress_hostname = local.notary_hostname

    ssl_redirect = var.root_zone_name == "localhost" ? false : true

    jobservice_pvc_size = "10Gi"
    database_pvc_size   = "10Gi"
    redis_pvc_size      = "10Gi"

    storage_class     = var.k8s_storage_class
    img_tag           = "v2.1.3"
  }
}

resource "helm_release" "harbor" {
  count      = var.enable ? 1 : 0
  repository = "https://helm.goharbor.io"
  name       = "harbor"
  namespace  = var.namespace
  chart      = "harbor"
  version    = "1.5.3"

  values = [
    data.template_file.harbor_values.rendered
  ]

  set_sensitive {
    name  = "harborAdminPassword"
    value = var.admin_password
  }

  set_sensitive {
    name  = "secretKey"
    value = random_string.harbor_secret_key.result
  }

  set_sensitive {
    name  = "core.secret"
    value = random_string.harbor_core_secret.result
  }

  set_sensitive {
    name  = "jobservice.secret"
    value = random_string.harbor_jobservice_secret.result
  }

  set_sensitive {
    name  = "registry.secret"
    value = random_string.harbor_registry_secret.result
  }

  set_sensitive {
    name  = "database.internal.password"
    value = random_string.harbor_db_password.result
  }

  depends_on = [
    helm_release.harbor_certificates,
    helm_release.harbor_volumes
  ]
}

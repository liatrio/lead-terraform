locals {
  harbor_hostname = "harbor.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  notary_hostname = "notary.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
}

resource "random_string" "harbor_admin_password" {
  length = 10
  special = false
}

resource "random_string" "harbor_db_password" {
  length = 10
  special = false
}

resource "random_string" "harbor_secret_key" {
  length = 16
  special = false
}

resource "random_string" "harbor_core_secret" {
  length = 16
  special = false
}

resource "random_string" "harbor_jobservice_secret" {
  length = 16
  special = false
}

resource "random_string" "harbor_registry_secret" {
  length = 16
  special = false
}

resource "helm_release" "harbor_volumes" {
  count = var.enable_harbor ? 1 : 0
  chart = "${path.module}/charts/harbor-volumes"
  name = "harbor-volumes"
  namespace = module.toolchain_namespace.name
  wait = true
  provider = helm.toolchain

  set {
    name = "components.registry.size"
    value = var.harbor_registry_disk_size
  }

  set {
    name = "components.chartmuseum.size"
    value = var.harbor_chartmuseum_disk_size
  }

  set {
    name = "storageClassName"
    value = var.k8s_storage_class
  }
}

resource "helm_release" "harbor_certificates" {
  count = var.enable_harbor ? 1 : 0
  chart = "${path.module}/charts/harbor-certificates"
  name = "harbor-certificates"
  namespace = module.toolchain_namespace.name
  wait = true
  provider = helm.toolchain

  set {
    name = "harbor.hostname"
    value = local.harbor_hostname
  }

  set {
    name = "notary.hostname"
    value = local.notary_hostname
  }

  set {
    name = "harbor.secret"
    value = "harbor-tls"
  }

  set {
    name = "notary.secret"
    value = "notary-tls"
  }

  set {
    name = "issuer.kind"
    value = var.issuer_kind
  }

  set {
    name = "issuer.name"
    value = var.issuer_name
  }
}

data "helm_repository" "harbor" {
  name = "harbor"
  url = "https://helm.goharbor.io"
  provider = helm.toolchain
}

data "template_file" "harbor_values" {
  template = file("${path.module}/harbor-values.tpl")

  vars = {
    harbor_ingress_hostname = local.harbor_hostname
    notary_ingress_hostname = local.notary_hostname

    ssl_redirect = var.root_zone_name == "localhost" ? false : true

    jobservice_pvc_size = "10Gi"
    database_pvc_size = "10Gi"
    redis_pvc_size = "10Gi"

    storage_class = var.k8s_storage_class
  }
}

resource "helm_release" "harbor" {
  count = var.enable_harbor ? 1 : 0
  repository = data.helm_repository.harbor.metadata[0].name
  name = "harbor"
  namespace = module.toolchain_namespace.name
  chart = "harbor"
  version = "1.3.0"
  provider = helm.toolchain

  values = [
    data.template_file.harbor_values.rendered
  ]

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

  depends_on = [
    helm_release.harbor_certificates,
    helm_release.harbor_volumes
  ]
}

resource "keycloak_openid_client" "harbor_client" {
  count = var.enable_harbor && var.enable_keycloak ? 1 : 0
  realm_id = keycloak_realm.realm[0].id
  client_id = "harbor"
  name = "harbor"
  enabled = true

  access_type = "CONFIDENTIAL"
  standard_flow_enabled = true

  valid_redirect_uris = [
    "https://${local.harbor_hostname}/c/oidc/callback"
  ]

  depends_on = [
    helm_release.harbor
  ]
}

resource "keycloak_openid_group_membership_protocol_mapper" "harbor_group_membership_mapper" {
  count = var.enable_harbor && var.enable_keycloak ? 1 : 0
  realm_id = keycloak_openid_client.harbor_client[0].realm_id
  client_id = keycloak_openid_client.harbor_client[0].id
  name = "harbor-group-membership-mapper"

  claim_name = "groups"
}

resource "helm_release" "harbor_config" {
  count = var.enable_harbor && var.enable_keycloak ? 1 : 0
  chart = "${path.module}/charts/harbor-config"
  name = "harbor-config"
  namespace = module.toolchain_namespace.name
  wait = true
  provider = helm.toolchain

  set {
    name = "harbor.username"
    value = "admin"
  }

  set_sensitive {
    name = "harbor.password"
    value = random_string.harbor_admin_password.result
  }

  set {
    name = "harbor.hostname"
    value = local.harbor_hostname
  }

  set {
    name = "keycloak.hostname"
    value = local.keycloak_hostname
  }

  set_sensitive {
    name = "keycloak.secret"
    value = keycloak_openid_client.harbor_client[0].client_secret
  }
}

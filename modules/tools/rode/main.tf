locals {
  auth_enabled = var.oidc_issuer_url != ""
  ingress_annotations = {
    "kubernetes.io/ingress.class" : var.ingress_class,
    "nginx.ingress.kubernetes.io/force-ssl-redirect" : "true",
  }
}

resource "helm_release" "rode" {
  repository = "https://rode.github.io/charts"
  name       = "rode"
  chart      = "rode"
  namespace  = var.namespace
  version    = "0.4.0"
  wait       = true

  set_sensitive {
    name  = "grafeas-elasticsearch.grafeas.elasticsearch.username"
    value = var.grafeas_elasticsearch_username
  }

  set_sensitive {
    name  = "grafeas-elasticsearch.grafeas.elasticsearch.password"
    value = var.grafeas_elasticsearch_password
  }

  values = [
    templatefile("${path.module}/rode-values.yaml.tpl", {
      ingress = {
        enabled = true
        http = {
          host        = var.rode_ingress_hostname
          annotations = local.ingress_annotations,
        }
        grpc = {
          host = var.rode_grpc_ingress_hostname
          annotations = merge(local.ingress_annotations, {
            "nginx.ingress.kubernetes.io/backend-protocol" : "GRPC",
          })
        }
      }

      oidc_config = {
        enabled : local.auth_enabled,
        issuer : var.oidc_issuer_url,
        requiredAudience : var.oidc_client_id,
        roleClaimPath : "resource_access.${var.oidc_client_id}.roles",
        tlsInsecureSkipVerify : false
      }

      grafeas_image_tag = var.grafeas_image_tag
    })
  ]
}

resource "helm_release" "rode_ui" {
  count = var.rode_ui_enabled ? 1 : 0

  repository = "https://rode.github.io/charts"
  name       = "rode-ui"
  chart      = "rode-ui"
  namespace  = var.namespace
  version    = "0.3.3"
  wait       = true

  set_sensitive {
    name  = "rode.auth.oidc.clientSecret"
    value = var.oidc_client_secret
  }

  values = [
    templatefile("${path.module}/rode-ui-values.yaml.tpl", {
      ingress_enabled  = true
      ingress_hostname = var.ui_ingress_hostname
      ingress_annotations = merge(local.ingress_annotations, {
        "nginx.ingress.kubernetes.io/proxy-buffer-size" : "8k",
      })

      oidc_config = {
        enabled : local.auth_enabled,
        clientId : var.oidc_client_id
        issuerUrl : var.oidc_issuer_url
      }
    })
  ]

  depends_on = [
    helm_release.rode,
  ]
}

resource "helm_release" "rode_tfsec_collector" {
  name       = "rode-collector-tfsec"
  namespace  = var.namespace
  repository = "https://rode.github.io/charts"
  chart      = "rode-collector-tfsec"
  version    = "0.2.1"
  wait       = true

  values = [
    templatefile("${path.module}/tfsec-collector-values.yaml.tpl", {
      auth_enabled        = local.auth_enabled
      host                = var.tfsec_collector_hostname
      ingress_annotations = local.ingress_annotations
      namespace           = var.namespace
    })
  ]

  depends_on = [
    helm_release.rode,
  ]
}

resource "helm_release" "rode_sonarqube_collector" {
  name       = "rode-collector-sonarqube"
  namespace  = var.namespace
  repository = "https://rode.github.io/charts"
  chart      = "rode-collector-sonarqube"
  version    = "0.1.0"
  wait       = true

  set_sensitive {
    name  = "rode.auth.oidc.clientSecret"
    value = var.collector_client_secret
  }

  values = [
    templatefile("${path.module}/sonar-collector-values.yaml.tpl", {
      oidc_auth_enabled = local.auth_enabled
      oidc_client_id    = var.collector_client_id
      oidc_token_url    = var.oidc_token_url
      namespace         = var.namespace
    })
  ]

  depends_on = [
    helm_release.rode,
  ]
}

resource "helm_release" "rode_collector_harbor" {
  name       = "rode-collector-harbor"
  namespace  = var.namespace
  chart      = "rode-collector-harbor"
  repository = "https://rode.github.io/charts"
  version    = "0.2.1"
  wait       = true

  set_sensitive {
    name  = "rode.auth.oidc.clientSecret"
    value = var.collector_client_secret
  }

  values = [
    templatefile("${path.module}/harbor-collector-values.yaml.tpl", {
      namespace         = var.namespace
      harbor_url        = var.harbor_url
      oidc_auth_enabled = local.auth_enabled
      oidc_client_id    = var.collector_client_id
      oidc_token_url    = var.oidc_token_url
    })
  ]
}

resource "helm_release" "rode_build_collector" {
  name       = "rode-collector-build"
  namespace  = var.namespace
  repository = "https://rode.github.io/charts"
  chart      = "rode-collector-build"
  version    = "0.4.0"
  wait       = true

  values = [
    templatefile("${path.module}/build-collector-values.yaml.tpl", {
      ingress = {
        enabled = true
        http = {
          host        = var.build_collector_hostname
          annotations = local.ingress_annotations,
        }
        grpc = {
          host = var.build_collector_grpc_hostname
          annotations = merge(local.ingress_annotations, {
            "nginx.ingress.kubernetes.io/backend-protocol" : "GRPC",
          })
        }
      }
      auth_enabled = local.auth_enabled
      namespace    = var.namespace
    })
  ]

  depends_on = [
    helm_release.rode,
  ]
}

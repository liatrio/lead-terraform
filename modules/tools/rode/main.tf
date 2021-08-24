locals {
  auth_enabled = var.oidc_issuer_url != ""
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
    templatefile("${path.module}/rode-values.tpl", {
      ingress = {
        enabled = true
        http = {
          host = var.rode_ingress_hostname
          annotations = {
            "kubernetes.io/ingress.class" : var.ingress_class,
            "nginx.ingress.kubernetes.io/force-ssl-redirect": "true",
          }
        }
        grpc = {
          host = var.rode_grpc_ingress_hostname
          annotations = {
            "nginx.ingress.kubernetes.io/backend-protocol": "GRPC",
            "nginx.ingress.kubernetes.io/force-ssl-redirect": "true",
          }
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
    templatefile("${path.module}/rode-ui-values.tpl", {
      ingress_enabled     = true
      ingress_hostname    = var.ui_ingress_hostname
      ingress_annotations = {
        "nginx.ingress.kubernetes.io/proxy-buffer-size" : "8k",
        "nginx.ingress.kubernetes.io/force-ssl-redirect": "true",
        "kubernetes.io/ingress.class" : var.ingress_class,
      }

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
      ingress_annotations = {
        "kubernetes.io/ingress.class" : var.ingress_class,
        "nginx.ingress.kubernetes.io/force-ssl-redirect": "true",
      }
      namespace           = var.namespace
    })
  ]

  depends_on = [
    helm_release.rode,
  ]
}

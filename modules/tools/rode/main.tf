resource "helm_release" "rode" {
  repository = "https://rode.github.io/charts"
  name       = "rode"
  chart      = "rode"
  namespace  = var.namespace
  version    = "0.3.3"
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
      ingress_enabled  = true
      ingress_hostname = var.rode_ingress_hostname
      ingress_annotations = {
        "kubernetes.io/ingress.class" : var.ingress_class
      }

      oidc_config = {
        enabled : var.oidc_issuer_url != "",
        issuer : var.oidc_issuer_url,
        requiredAudience : var.oidc_issuer_client_id,
        roleClaimPath : "resource_access.${var.oidc_issuer_client_id}.roles",
        tlsInsecureSkipVerify : false
      }

      grafeas_image_tag = var.grafeas_image_tag
    })
  ]
}

resource "helm_release" "rode_ui" {
  count = var.ui_ingress_hostname == "" ? 0 : 1

  repository = "https://rode.github.io/charts"
  name       = "rode-ui"
  chart      = "rode-ui"
  namespace  = var.namespace
  version    = "0.3.3"
  wait       = true

  set_sensitive {
    name  = "rode.auth.oidc.clientSecret"
    value = var.oidc_issuer_client_secret
  }

  values = [
    templatefile("${path.module}/rode-ui-values.tpl", {
      ingress_enabled  = true
      ingress_hostname = var.ui_ingress_hostname
      ingress_annotations = {
        "nginx.ingress.kubernetes.io/proxy-buffer-size" : "8k"
        "kubernetes.io/ingress.class" : var.ingress_class
      }

      oidc_config = {
        enabled : var.oidc_issuer_url != "",
        clientId : var.oidc_issuer_client_id
        issuerUrl : var.oidc_issuer_url
      }
    })
  ]
}

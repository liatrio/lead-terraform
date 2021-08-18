resource "helm_release" "rode" {
  repository = "https://harbor.toolchain.lead.prod.liatr.io/chartrepo/public"
  timeout    = 120
  name       = "rode"
  chart      = "rode"
  namespace  = var.namespace
  version    = "0.3.2"
  wait = true

  set_sensitive {
    name  = "grafeas-elasticsearch.grafeas.elasticsearch.username"
    value = "grafeas"
  }

  set_sensitive {
    name  = "grafeas-elasticsearch.grafeas.elasticsearch.password"
    value = "grafeas-temp"
  }

  set_sensitive {
    name  = "auth.oidc.clientSecret"
    value = var.oidc_issuer_client_secret
  }

  set_sensitive {
    name  = "rode-ui.auth.oidc.clientSecret"
    value = var.oidc_issuer_client_secret
  }

  values = [
    templatefile("${path.module}/rode-values.tpl", {
      ingress_enabled     = true
      ingress_hostname    = "rode.${var.ingress_domain}"
      ui_ingress_hostname    = "rode-dashboard.${var.ingress_domain}"
      ingress_annotations = {
        "kubernetes.io/ingress.class" : var.ingress_class
      }

      oidc_config = {
        enabled: var.oidc_issuer_url == "" ? false: true,
        clientId: var.oidc_issuer_client_id
        clientSecret: var.oidc_issuer_client_secret
        issuerUrl: var.oidc_issuer_url
      }
    })
  ]
}


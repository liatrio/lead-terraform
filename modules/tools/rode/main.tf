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
    value = var.grafeas_elasticsearch_username
  }

  set_sensitive {
    name  = "grafeas-elasticsearch.grafeas.elasticsearch.password"
    value = var.grafeas_elasticsearch_password
  }

  set_sensitive {
    name  = "auth.oidc.clientSecret"
    value = var.oidc_issuer_client_secret
  }

  set_sensitive {
    name  = "rode-ui.rode.auth.oidc.clientSecret"
    value = var.oidc_issuer_client_secret
  }

  values = [
    templatefile("${path.module}/rode-values.tpl", {
      ingress_enabled     = true
      ingress_hostname    = var.rode_ingress_hostname
      ui_ingress_hostname = var.ui_ingress_hostname
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


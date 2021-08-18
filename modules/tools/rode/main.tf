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

  values = [
    templatefile("${path.module}/rode-values.tpl", {
      ingress_enabled   = true
      ingress_hostname  = "rode-api.${var.ingress_domain}"
      ingress_annotations = {
        "kubernetes.io/ingress.class" : var.ingress_class
      }
      ui_ingress_enabled   = true
      ui_ingress_hostname  = "rode.${var.ingress_domain}"
      ui_ingress_annotations = {
        "kubernetes.io/ingress.class" : var.ingress_class
      }
    })
  ]
}


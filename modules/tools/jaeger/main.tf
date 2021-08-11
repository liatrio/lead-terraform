locals {
  jaeger_zipkin_port = 9411
  jaeger_query_port  = 16686

  jaeger_query_external_hostname = "jaeger.${var.toolchain_namespace}.${var.cluster_domain}"
}

resource "kubernetes_secret" "elasticsearch_password" {
  metadata {
    name      = "elasticsearch-password"
    namespace = var.namespace
  }

  data = {
    password = var.elasticsearch_password
  }
}

resource "helm_release" "jeager" {
  name       = "jaeger"
  namespace  = var.namespace
  chart      = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  version    = "0.27.3"
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      elasticsearch_host                 = var.elasticsearch_host
      elasticsearch_username             = var.elasticsearch_username
      elasticsearch_password_secret_name = kubernetes_secret.elasticsearch_password.metadata[0].name

      jaeger_zipkin_port = local.jaeger_zipkin_port
      jaeger_query_port  = local.jaeger_query_port
    })
  ]
}

resource "kubernetes_ingress" "jaeger" {
  metadata {
    namespace = var.namespace
    name      = "jaeger"

    annotations = {
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "kubernetes.io/ingress.class"                    = var.ingress_class
    }
  }
  spec {
    rule {
      host = local.jaeger_query_external_hostname
      http {
        path {
          path = "/"
          backend {
            service_name = "jaeger-query"
            service_port = local.jaeger_query_port
          }
        }
      }
    }
  }
}

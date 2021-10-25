locals {
  ingress_class = "vcluster"
}

resource "kubernetes_namespace" "vcluster" {
  metadata {
    name = var.namespace
  }
}

// we need a dedicated instance of ingress-nginx in order to enable ssl passthrough to the k8s API server.
// we could technically enable this on an existing instance of ingress-nginx, but there's a noticable performance hit
module "nginx" {
  source = "../nginx"

  name          = "vcluster"
  namespace     = kubernetes_namespace.vcluster.metadata[0].name
  internal      = true
  ingress_class = local.ingress_class
  cluster_wide  = false
  extra_args    = {
    "enable-ssl-passthrough" : "true"
  }
}

resource "helm_release" "vcluster" {
  repository = "https://charts.loft.sh"
  name       = "vcluster"
  namespace  = kubernetes_namespace.vcluster.metadata[0].name
  chart      = "vcluster"
  version    = "0.4.1"
  timeout    = 300
  wait       = true

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      vcluster_hostname            = var.vcluster_hostname
      host_cluster_service_ip_cidr = var.host_cluster_service_ip_cidr
    })
  ]
}

resource "kubernetes_ingress" "vcluster" {
  metadata {
    name = "vcluster"
    namespace = kubernetes_namespace.vcluster.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = local.ingress_class
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      "nginx.ingress.kubernetes.io/ssl-passthrough" = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }
  spec {
    rule {
      host = var.vcluster_hostname
      http {
        path {
          backend {
            service_name = "vcluster"
            service_port = 443
          }
          path = "/"
        }
      }
    }
  }

  depends_on = [
    module.nginx
  ]
}

resource "tls_private_key" "ca_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca_cert" {
  key_algorithm   = tls_private_key.ca_private_key.algorithm
  private_key_pem = tls_private_key.ca_private_key.private_key_pem

  validity_period_hours = 24 * 365 * 10

  is_ca_certificate = true

  subject {
    common_name = var.vcluster_apiserver_host
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "cert_signing",
  ]
}

resource "kubernetes_namespace" "vcluster" {
  metadata {
    name = var.host_cluster_namespace
  }
}

resource "kubernetes_secret" "signing_cert_and_key" {
  metadata {
    name      = "vcluster-signing-cert-and-key"
    namespace = kubernetes_namespace.vcluster.metadata[0].name
  }

  data = {
    "cert.pem" = tls_self_signed_cert.ca_cert.cert_pem
    "key.pem"  = tls_private_key.ca_private_key.private_key_pem
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
    templatefile("${path.module}/vcluster-values.yaml.tpl", {
      signing_cert_and_key_secret_name = kubernetes_secret.signing_cert_and_key.metadata[0].name
      api_server_host                  = var.vcluster_apiserver_host
      host_cluster_service_cidr        = var.host_cluster_service_cidr
    })
  ]
}

resource "kubernetes_ingress" "vcluster" {
  metadata {
    name      = "vcluster"
    namespace = kubernetes_namespace.vcluster.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      "nginx.ingress.kubernetes.io/ssl-passthrough"  = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "true"
      "kubernetes.io/ingress.class"                  = var.vcluster_apiserver_ingress_class
    }
  }
  spec {
    rule {
      host = var.vcluster_apiserver_host
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
    helm_release.vcluster
  ]
}

data "kubernetes_secret" "vcluster_kubeconfig" {
  metadata {
    namespace = helm_release.vcluster.namespace
    name      = "vc-${helm_release.vcluster.name}"
  }
}

# it's strange to do what is essentially two separate checks to ensure the cluster is up and reachable, but only doing one
# of the two checks didn't have a 100% success rate when running this locally. using both checks seems to work every time.
# module "wait_for_vcluster" {
#   source = "matti/resource/shell"

#   command = <<EOF
# until nslookup ${var.vcluster_apiserver_host} &>/dev/null; do
#   sleep 10
# done

# until curl --output /dev/null --silent -4 --fail --max-time 2 --insecure https://${var.vcluster_apiserver_host}/healthz; do
#   sleep 10
# done
# EOF

#   depends_on = [
#     helm_release.vcluster,
#     kubernetes_ingress.vcluster,
#     data.kubernetes_secret.vcluster_kubeconfig
#   ]
# }

resource "null_resource" "wait_for_vcluster_dns" {
  triggers = {
    # vcluster_apiserver_host = var.vcluster_apiserver_host
  }

  provisioner "local-exec" {
    command = <<EOF
until nslookup ${var.vcluster_apiserver_host} &>/dev/null; do
  sleep 10
done
EOF
  }

  depends_on = [
    helm_release.vcluster,
    kubernetes_ingress.vcluster,
    data.kubernetes_secret.vcluster_kubeconfig
  ]
}

resource "null_resource" "wait_for_vcluster_api" {
  triggers = {
    # vcluster_apiserver_host = var.vcluster_apiserver_host
  }

  provisioner "local-exec" {
    command = <<EOF
until curl --output /dev/null --silent -4 --fail --max-time 2 --insecure https://${var.vcluster_apiserver_host}/healthz; do
  sleep 10
done
EOF
  }

  depends_on = [
    null_resource.wait_for_vcluster_dns
  ]
}

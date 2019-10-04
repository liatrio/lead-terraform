resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm = "${tls_private_key.ca.algorithm}"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  is_ca_certificate = true

  subject {
    common_name = "${var.common_name}"
    organization = "${var.organization_name}"
  }

  validity_period_hours = 12

  early_renewal_hours = 3

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature"
  ]
}

resource "kubernetes_secret" "ca" {
  metadata {
    name = "ca-issuer-${var.name}"
    namespace = "${var.namespace}"
    labels = {
      "app.kubernetes.io/name"       = "ca-issuer-${var.name}"
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  type  = "tls"

  data = {
    "tls.crt"  = "${tls_self_signed_cert.ca.cert_pem}"
    "tls.key"   = "${tls_private_key.ca.private_key_pem}"
  }
}

module "cert-issuer" {
  source = "../cert-issuer"
  
  namespace = "${var.namespace}"
  issuer_name = "ca-issuer-${var.name}"
  issuer_type = "ca"
  ca_secret = "ca-issuer-${var.name}"
  crd_waiter = "${var.cert-manager-crd}"
}
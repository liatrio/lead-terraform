locals {
  elasticsearch_username = "elastic"
}

module "ca_issuer" {
  source = "../../common/ca-issuer"

  name        = "elasticstack"
  namespace   = var.namespace
  common_name = var.root_zone_name
}

module "elasticsearch_certificate" {
  source = "../../common/certificates"

  name          = "elasticsearch-certs"
  namespace     = var.namespace
  domain        = "elasticsearch-master.${var.namespace}.svc"
  issuer_name   = module.ca_issuer.name
  wait_for_cert = true
}

resource "random_password" "elasticsearch_password" {
  length  = 12
  special = false
}

resource "kubernetes_secret" "elasticsearch_credentials" {
  metadata {
    name      = "elasticsearch-credentials"
    namespace = var.namespace
  }

  data = {
    username = local.elasticsearch_username
    password = random_password.elasticsearch_password.result
  }
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  namespace  = var.namespace
  chart      = "elasticsearch"
  repository = "https://helm.elastic.co"
  version    = "7.7.0"
  wait       = true
  timeout    = 600

  values = [
    templatefile("${path.module}/elasticsearch-values.tpl", {
      local                                 = var.local
      replicas                              = var.replicas
      k8s_storage_class                     = var.k8s_storage_class
      disk_size                             = var.disk_size
      elasticsearch_certs_secret_name       = module.elasticsearch_certificate.cert_secret_name
      elasticsearch_credentials_secret_name = kubernetes_secret.elasticsearch_credentials.metadata[0].name
    })
  ]
}
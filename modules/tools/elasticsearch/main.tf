locals {
  elasticsearch_username = "elastic"
}

module "ca_issuer" {
  source = "../../common/ca-issuer"

  name             = "elasticstack"
  namespace        = var.namespace
  common_name      = var.root_zone_name
  cert-manager-crd = var.cert_manager_crd_waiter
}

module "elasticsearch_certificate" {
  source = "../../common/certificates"

  name            = "elasticsearch-certs"
  namespace       = var.namespace
  domain          = "elasticsearch-master.${var.namespace}.svc"
  issuer_name     = module.ca_issuer.name
  certificate_crd = var.cert_manager_crd_waiter
  wait_for_cert   = true
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

data "helm_repository" "elastic" {
  name = "elastic"
  url  = "https://helm.elastic.co"
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  namespace  = var.namespace
  chart      = "elastic/elasticsearch"
  repository = data.helm_repository.elastic.name
  version    = "7.6.2"
  wait       = true

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

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "elasticsearch_curator" {
  name       = "elasticsearch-curator"
  namespace  = var.namespace
  chart      = "stable/elasticsearch-curator"
  repository = data.helm_repository.stable.name
  version    = "2.1.5"
  wait       = true

  values = [
    templatefile("${path.module}/elasticsearch-curator-values.tpl", {
      elasticsearch_host       = "elasticsearch-master.${var.namespace}.svc.cluster.local"
      days_until_index_expires = 14
    })
  ]

  depends_on = [
    helm_release.elasticsearch
  ]
}

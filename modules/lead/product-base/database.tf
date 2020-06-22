module "database_namespace" {
  source    = "../../common/namespace"
  namespace = "${var.product_name}-db"
  labels = {
    "istio-injection"                        = "enabled"
    "appmesh.k8s.aws/sidecarInjectorWebhook" = "enabled"
  }
  annotations = {
    name                                 = "${var.product_name}-db"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-db.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist"   = var.image_whitelist
  }
}

data "helm_repository" "bitnami" {
  name  = "bitnami"
  url   = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "mongo-db" {
  name      = "mongo-db"
  namespace = module.database_namespace.name
  chart     = "${path.module}/charts/mongo"
  wait      = true
}

resource "helm_release" "mongo-db" {
  name       = "mongo-db"
  namespace  = module.database_namespace.name
  repository = data.helm_repository.bitnami.name
  chart      = "bitnami/mongodb"
  version    = "4.2.8"
  timeout    = 600
  wait       = true

}
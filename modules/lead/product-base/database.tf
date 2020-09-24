module "database_namespace" {
  source      = "../../common/namespace"
  namespace   = "${var.product_name}-db"
  labels      = {
    "istio-injection"                        = "enabled"
    "appmesh.k8s.aws/sidecarInjectorWebhook" = "enabled"
  }
  annotations = {
    name                                 = "${var.product_name}-db"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-db.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist"   = var.image_whitelist
  }

  providers = {
    helm       = helm.system
    kubernetes = kubernetes.system
  }
}

resource "random_password" "mongodb_root_password" {
  length  = 8
  special = false
}

resource "helm_release" "mongodb" {
  provider   = helm.system
  name       = "mongodb"
  namespace  = module.database_namespace.name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "bitnami/mongodb"
  version    = "7.14.8"
  timeout    = 600
  wait       = true

  values = [
    templatefile("${path.module}/mongo.tpl", {
      mongodbRootPassword = random_password.mongodb_root_password.result
    })
  ]
}

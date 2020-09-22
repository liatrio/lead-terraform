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

  providers = {
    helm       = helm.system
    kubernetes = kubernetes.system
  }
}

data "template_file" "mongo_values" {
  template = file("${path.module}/mongo.tpl")
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

  values = [data.template_file.mongo_values.rendered]
}

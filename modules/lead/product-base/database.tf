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
    helm       = helm.staging
    kubernetes = kubernetes.staging
  }
}

// Create Jenkins service account
resource "kubernetes_service_account" "mongo" {
  provider = kubernetes.staging
  metadata {
    name      = "db_svc_account"
    namespace = module.database_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "mongo"
      "app.kubernetes.io/instance"   = "mongo"
      "app.kubernetes.io/component"  = "mongo"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Service account for db namespace"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  automount_service_account_token = true
}

resource "helm_release" "mongo-db" {
  name      = "mongo-db"
  namespace = module.database_namespace.name
  chart     = "${path.module}/charts/mongo"
  wait      = true
}
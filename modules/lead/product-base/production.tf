module "production_namespace" {
  source    = "../../common/namespace"
  namespace = "${var.product_name}-production"
  labels = {
    "istio-injection"                        = "enabled"
    "appmesh.k8s.aws/sidecarInjectorWebhook" = "enabled"
  }
  annotations = {
    name                                 = "${var.product_name}-production"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-production.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist"   = var.image_whitelist
  }
  providers = {
    helm       = helm.production
    kubernetes = kubernetes.production
  }
}

resource "helm_release" "production_product_init" {
  name      = "product-init"
  namespace = module.production_namespace.name
  chart     = "${path.module}/helm/product-init"
  timeout   = 600
  wait      = true

  provider  = helm.production
}

resource "kubernetes_role" "default_production_role" {
  provider = kubernetes.production
  metadata {
    name      = "default-production-role"
    namespace = module.production_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "default"
      "app.kubernetes.io/instance"   = "default"
      "app.kubernetes.io/component"  = "default-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for default Service Account to get pods and jobs in production namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "default_production_rolebinding" {
  provider = kubernetes.production
  metadata {
    name      = "default-production-rolebinding"
    namespace = module.production_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "default"
      "app.kubernetes.io/instance"   = "default"
      "app.kubernetes.io/component"  = "default-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for default Service account to get pods and jobs in production namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.default_production_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace   = module.production_namespace.name
  }
}

resource "kubernetes_role" "ci_production_role" {
  provider = kubernetes.production
  metadata {
    name      = "ci-production-role"
    namespace = module.production_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "ci"
      "app.kubernetes.io/instance"   = "ci"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Continous Integration tools to get pods in production namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  rule {
    api_groups = ["", "extensions", "apps", "batch", "networking.istio.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

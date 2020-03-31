module "staging_namespace" {
  source    = "../../common/namespace"
  namespace = "${var.product_name}-staging"
  labels = {
    "istio-injection"                        = "enabled"
    "appmesh.k8s.aws/sidecarInjectorWebhook" = "enabled"
  }
  annotations = {
    name                                 = "${var.product_name}-staging"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-staging.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist"   = var.image_whitelist
  }
  providers = {
    helm       = helm.staging
    kubernetes = kubernetes.staging
  }
}

resource "helm_release" "staging_product_init" {
  name      = "product-init"
  namespace = module.staging_namespace.name
  chart     = "${path.module}/helm/product-init"
  timeout   = 600
  wait      = true

  provider  = helm.staging
}


resource "kubernetes_role" "default_staging_role" {
  provider = kubernetes.staging
  metadata {
    name      = "default-staging-role"
    namespace = module.staging_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "default"
      "app.kubernetes.io/instance"   = "default"
      "app.kubernetes.io/component"  = "default-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for default Service Account to get pods and jobs in staging namespace"
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

resource "kubernetes_role_binding" "default_staging_rolebinding" {
  provider = kubernetes.staging
  metadata {
    name      = "default-staging-rolebinding"
    namespace = module.staging_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "default"
      "app.kubernetes.io/instance"   = "default"
      "app.kubernetes.io/component"  = "default-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for default Service account to get pods and jobs in staging namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.default_staging_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace   = module.staging_namespace.name
  }
}

resource "kubernetes_role" "ci_staging_role" {
  provider = kubernetes.staging
  metadata {
    name      = "ci-staging-role"
    namespace = module.staging_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "ci"
      "app.kubernetes.io/instance"   = "ci"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Continous Integration tools to get pods in staging namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  rule {
    api_groups = ["", "extensions", "apps", "batch"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

locals {
  vault_mongodb_production_role = "${var.product_name}-production"
}

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
    api_groups = ["extensions", "apps"]
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
    namespace = module.production_namespace.name
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
    api_groups = ["", "extensions", "apps", "batch"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["networking.istio.io"]
    resources  = ["*"]
    verbs      = ["list", "watch", "create", "patch", "get", "delete", "update"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["flagger.app"]
    resources  = ["canaries", "canaries/status"]
    verbs      = ["*"]
  }
}

resource "vault_database_secret_backend_role" "mongodb_production_role" {
  backend = "mongodb"
  creation_statements = [
    jsonencode({
      db = "admin"
      roles = [
        {
          role = "readWrite"
          db   = "production"
        }
      ]
    })
  ]

  db_name = vault_database_secret_backend_connection.mongodb.name
  name    = local.vault_mongodb_production_role

  default_ttl = 600
  max_ttl     = 600
}

resource "vault_kubernetes_auth_backend_role" "k8s_auth_role_production" {
  backend = "/kubernetes"
  bound_service_account_names = [
    "*"
  ]
  bound_service_account_namespaces = [
    "${var.product_name}-production"
  ]

  role_name = "${var.product_name}-production"

  token_ttl     = 300
  token_max_ttl = 300
  token_policies = [
    vault_policy.mongodb_credentials_policy.name,
    "default"
  ]
}

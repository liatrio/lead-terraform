locals {
  vault_mongodb_role = "${var.product_name}-mongodb"
}

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
    namespace = module.staging_namespace.name
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

resource "vault_mount" "mongodb" {
  path = "${var.product_name}-staging"
  type = "database"

  depends_on = [
    helm_release.mongodb
  ]
}

resource "vault_database_secret_backend_connection" "mongodb" {
  backend = vault_mount.mongodb.path
  name    = "${var.product_name}-staging-mongodb"

  allowed_roles = [
    local.vault_mongodb_role
  ]

  data = {
    username = "root"
    password = "changeme"
  }

  mongodb {
    connection_url = "mongodb://{{username}}:{{password}}@mongodb.${var.product_name}-db.svc.cluster.local/admin"
  }
}

resource "vault_database_secret_backend_role" "mongodb_role" {
  backend = vault_mount.mongodb.path
  creation_statements = [
    jsonencode({
      db = "admin"
      roles = [
        {
          role = "readWrite"
          db   = "foo"
        }
      ]
    })
  ]

  db_name = vault_database_secret_backend_connection.mongodb.name
  name    = local.vault_mongodb_role

  default_ttl = 60
  max_ttl     = 60
}

resource "vault_policy" "get_mongodb_creds" {
  name   = "get-${var.product_name}-mongodb-creds"
  policy = <<EOF
path "${var.product_name}-staging/creds/mongodb" {
  capabilities = ["read"]
}
EOF
}

resource "vault_kubernetes_auth_backend_role" "vault_auth_role" {
  backend = "/kubernetes"
  bound_service_account_names = [
    "*"
  ]
  bound_service_account_namespaces = [ // Can scope this to just <product>-staging at end
    "*"
  ]
  role_name = "${var.product_name}-auth-role"

  token_ttl     = 300
  token_max_ttl = 300
  token_policies = [
    vault_policy.get_mongodb_creds.name,
    "default"
  ]
}

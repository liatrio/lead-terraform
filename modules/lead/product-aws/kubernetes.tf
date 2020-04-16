resource "kubernetes_role_binding" "codebuild_staging_rolebinding" {
  provider = kubernetes.staging
  metadata {
    name      = "codebuild-staging-rolebinding"
    namespace = module.product_base.staging_namespace

    labels = {
      "app.kubernetes.io/name"       = "codebuild"
      "app.kubernetes.io/instance"   = "codebuild"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for codebuild' to get pods in staging namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = module.product_base.ci_staging_role_name
  }

  subject {
    kind      = "User"
    name      = var.codebuild_user
    api_group = "rbac.authorization.k8s.io"

  }
}

resource "kubernetes_role_binding" "codebuild_production_rolebinding" {
  provider = kubernetes.production
  metadata {
    name      = "codebuild-production-rolebinding"
    namespace = module.product_base.production_namespace

    labels = {
      "app.kubernetes.io/name"       = "codebuild"
      "app.kubernetes.io/instance"   = "codebuild"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' to get pods in production namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = module.product_base.ci_production_role_name
  }

  subject {
    kind      = "User"
    name      = var.codebuild_user
    api_group = "rbac.authorization.k8s.io"

  }
}

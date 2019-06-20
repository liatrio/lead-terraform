module "staging_namespace" {
  source     = "../../common/namespace"
  namespace  = "${var.product_name}-staging"
  annotations {
    name  = "${var.product_name}-staging"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-staging.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
  }
  providers {
    helm = "helm.staging"
    kubernetes = "kubernetes.staging"
  }
}

module "staging_ingress" {
  source = "../../common/nginx-ingress"
  namespace  = "${module.staging_namespace.name}"
  ingress_controller_type = "${var.ingress_controller_type}"

  providers {
    helm = "helm.staging"
    kubernetes = "kubernetes.staging"
  }
}

module "staging_issuer" {
  source = "../../common/cert-issuer"
  namespace  = "${module.staging_namespace.name}"
  issuer_type = "${var.issuer_type}"
  crd_waiter  = ""

  providers {
    helm = "helm.staging"
  }
}

resource "kubernetes_role" "staging_delete" {
  provider  = "kubernetes.toolchain"
  metadata {
    name      = "staging-delete"
    namespace = "${var.product_name}-toolchain"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations {
      description = "Permission required for Jenkins' to get pods in staging namespace"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["delete", "get", "list"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["deployments"]
    verbs      = ["delete", "get", "list"]
  }
}

resource "kubernetes_role_binding" "staging_delete" {
  provider  = "kubernetes.toolchain"
  metadata {
    name      = "staging-delete-resources"
    namespace = "${var.product_name}-toolchain"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations {
      description = "Permission required for Jenkins' to get pods in staging namespace"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${kubernetes_role.staging_delete.metadata.0.name}"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "jon-test-staging"
  }
}

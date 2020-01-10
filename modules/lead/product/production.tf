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

module "production_certificate" {
  source = "../../common/certificates"
  namespace = "istio-system"
  name = module.production_namespace.name
  domain = "${module.production_namespace.name}.${var.cluster_domain}"
  enabled = var.enable_istio
  certificate_crd = "set"

  providers = {
    helm = "helm.system"
    kubernetes = "kubernetes.system"
  }
}

module "production_ingress" {
  source                  = "../../common/nginx-ingress"
  namespace               = module.production_namespace.name
  ingress_controller_type = var.ingress_controller_type
  enabled                 = var.enable_istio ? false : true

  providers = {
    helm       = helm.production
    kubernetes = kubernetes.production
  }
}

resource "kubernetes_role" "jenkins_production_role" {
  provider = kubernetes.production
  metadata {
    name      = "jenkins-production-role"
    namespace = module.production_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' to get pods in production namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "jenkins_production_rolebinding" {
  provider = kubernetes.production
  metadata {
    name      = "jenkins-production-rolebinding"
    namespace = module.production_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
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
    name      = kubernetes_role.jenkins_production_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = module.toolchain_namespace.name
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

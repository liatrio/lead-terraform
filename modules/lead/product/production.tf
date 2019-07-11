
module "production_namespace" {
  source     = "../../common/namespace"
  namespace  = "${var.product_name}-production"
  labels {
    "istio-injection" = "enabled"
    "appmesh.k8s.aws/sidecarInjectorWebhook" = "enabled"
  }
  annotations {
    name  = "${var.product_name}-production"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-production.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
  }
  providers {
    helm = "helm.production"
    kubernetes = "kubernetes.production"
  }
}

module "production_certificate" {
  source = "../../common/certificates"
  namespace = "${var.module.production_namespace.name}"
  account = "${var.account}"
  enabled = "${var.istio_enabled}"

  providers {
    helm = "helm.production"
    kubernetes = "kubernetes.production"
  }
}

module "production_ingress" {
  source = "../../common/nginx-ingress"
  namespace  = "${module.production_namespace.name}"
  ingress_controller_type = "${var.ingress_controller_type}"
  enabled = "${var.istio_enabled ? false : true}"

  providers {
    helm = "helm.production"
    kubernetes = "kubernetes.production"
  }
}

data "template_file" "jenkins_values" {
  template = "${file("${path.module}/certificate.tpl")}"

  vars = {
    namespace = "${module.production_namespace.name}"
    account = "${}"
  }
}


module "production_issuer" {
  source = "../../common/cert-issuer"
  namespace  = "${module.production_namespace.name}"
  issuer_type = "${var.issuer_type}"
  crd_waiter  = ""

  providers {
    helm = "helm.production"
  }
}

resource "kubernetes_role" "jenkins_production_role" {
  provider  = "kubernetes.production"
  metadata {
    name      = "jenkins-production-role"
    namespace  = "${module.production_namespace.name}"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations {
      description = "Permission required for Jenkins' to get pods in production namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  rule {
    api_groups = ["","extensions"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "jenkins_production_rolebinding" {
  provider  = "kubernetes.production"
  metadata {
    name      = "jenkins-production-rolebinding"
    namespace  = "${module.production_namespace.name}"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations {
      description = "Permission required for Jenkins' to get pods in production namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${kubernetes_role.jenkins_production_role.metadata.0.name}"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.jenkins.metadata.0.name}"
    namespace = "${module.toolchain_namespace.name}"
  }
}

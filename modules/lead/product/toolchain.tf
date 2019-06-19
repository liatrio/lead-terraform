resource "random_string" "jenkins_admin_password" {
  length  = 10
  special = false
}

data "template_file" "jenkins_values" {
  template = "${file("${path.module}/jenkins-values.tpl")}"

  vars = {
    product_name     = "${var.product_name}"
    ingress_hostname = "jenkins.${module.toolchain_namespace.name}.${var.cluster_domain}"
    artifactory_url  = "artifactory.toolchain.${var.cluster_domain}/docker-registry"
    namespace        = "${module.toolchain_namespace.name}"
    logstash_url     = "http://lead-dashboard-logstash.toolchain.svc.cluster.local:9000"
    slack_team       = "liatrio"
  }
}

module "toolchain_namespace" {
  source     = "../../common/namespace"
  namespace  = "${var.product_name}-toolchain"
  annotations {
    name  = "${var.product_name}-toolchain"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-toolchain.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
  }

  providers {
    helm = "helm.toolchain"
    kubernetes = "kubernetes.toolchain"
  }
}

module "toolchain_ingress" {
  source = "../../common/nginx-ingress"
  namespace  = "${module.toolchain_namespace.name}"
  ingress_controller_type = "${var.ingress_controller_type}"

  providers {
    helm = "helm.toolchain"
    kubernetes = "kubernetes.toolchain"
  }
}

module "toolchain_issuer" {
  source = "../../common/cert-issuer"
  namespace  = "${module.toolchain_namespace.name}"
  issuer_type = "${var.issuer_type}"
  crd_waiter  = ""

  providers {
    helm = "helm.toolchain"
  }
}

resource "helm_release" "jenkins" {
  provider  = "helm.toolchain"
  name      = "jenkins"
  chart     = "stable/jenkins"
  namespace = "${module.toolchain_namespace.name}"
  timeout   = "300"

  set_sensitive {
    name  = "master.adminPassword"
    value = "${random_string.jenkins_admin_password.result}"
  }

  values = ["${data.template_file.jenkins_values.rendered}"]
}

// Create Jenkins service account
resource "kubernetes_service_account" "jenkins" {
  provider  = "kubernetes.toolchain"
  metadata {
    name      = "jenkins"
    namespace = "${module.toolchain_namespace.name}"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations {
      description = "Service account for Jenkins"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  automount_service_account_token = true
}

// Add roll to allow Jenkins to read secrets
resource "kubernetes_role" "jenkins_kubernetes_credentials" {
  provider  = "kubernetes.toolchain"
  metadata {
    name      = "jenkins-kubernetes-credentials"
    namespace = "${module.toolchain_namespace.name}"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to read secrets"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "watch", "list"]
  }
}

// Bind Kubernetes secrets role to Jenkins service account
resource "kubernetes_role_binding" "jenkins_kubernetes_credentials" {
  provider  = "kubernetes.toolchain"
  metadata {
    name      = "jenkins-kubernetes-credentials"
    namespace = "${module.toolchain_namespace.name}"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to read secrets"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${kubernetes_role.jenkins_kubernetes_credentials.metadata.0.name}"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.jenkins.metadata.0.name}"
    namespace = "${module.toolchain_namespace.name}"
  }
}

resource "kubernetes_cluster_role" "jenkins_get_pods" {
  provider  = "kubernetes.toolchain"
  metadata {
    name      = "jenkins-kubernetes-credentials"
    namespace = "${module.toolchain_namespace.name}"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations {
      description = "Permission required for Jenkins' to get pods"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["list"]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins_get_pods" {
  provider  = "kubernetes.toolchain"
  metadata {
    name      = "jenkins-kubernetes-credentials"
    namespace = "${module.toolchain_namespace.name}"

    labels {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations {
      description = "Permission required for Jenkins' to get pods"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${kubernetes_cluster_role.jenkins_get_pods.metadata.0.name}"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.jenkins.metadata.0.name}"
    namespace = "${module.toolchain_namespace.name}"
  }
}

resource "random_string" "jenkins_admin_password" {
  length  = 10
  special = false
}

data "template_file" "jenkins_values" {
  template = "${file("${path.module}/jenkins-values.tpl")}"

  vars = {
    ingress_hostname = "jenkins.${var.namespace}.${var.cluster}.${var.root_zone_name}"
    namespace        = "${var.namespace}"
    logstash_url     = "http://lead-dashboard-logstash.${var.namespace}.svc.cluster.local:9000"
    anchore_url      = "http://anchore-engine-anchore-engine-api.${var.namespace}.svc.cluster.local:8228/v1"
    anchore_user     = "admin"
    anchore_pass     = "${random_string.anchore_admin_password.result}"
    slack_team       = "liatrio"
  }
}

resource "helm_release" "jenkins" {
  name      = "jenkins"
  chart     = "stable/jenkins"
  namespace = "${var.namespace}"

  set_sensitive {
    name  = "master.adminPassword"
    value = "${random_string.jenkins_admin_password.result}"
  }

  values = ["${data.template_file.jenkins_values.rendered}"]
}

// Create Jenkins service account
resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = "${var.namespace}"

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
  metadata {
    name      = "jenkins-kubernetes-credentials"
    namespace = "${var.namespace}"

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
  metadata {
    name      = "jenkins-kubernetes-credentials"
    namespace = "${var.namespace}"

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
    name      = "jenkins-kubernetes-credentials"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "jenkins"
    namespace = "${var.namespace}"
  }
}
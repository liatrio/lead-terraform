resource "random_string" "jenkins_admin_password" {
  length  = 10
  special = false
}

data "template_file" "jenkins_values" {
  template = file("${path.module}/jenkins-values.tpl")

  vars = {
    cluster_domain         = var.cluster_domain
    toolchain_image_repo   = var.toolchain_image_repo
    jenkins_image_version  = var.jenkins_image_version
    product_name           = var.product_name
    protocol               = local.protocol
    ssl_redirect           = local.protocol == "http" ? false : true
    product_image_repo     = var.product_image_repo
    ingress_hostname       = "${module.toolchain_namespace.name}.jenkins.${var.cluster_domain}"
    namespace              = module.toolchain_namespace.name
    toolchain_namespace    = var.toolchain_namespace
    logstash_url           = "http://lead-dashboard-logstash.toolchain.svc.cluster.local:9000"
    slack_team             = "liatrio"
    stagingNamespace       = module.product_base.staging_namespace.name
    productionNamespace    = module.product_base.production_namespace.name
    appDomain              = "apps.${var.cluster_domain}"
    builder_images_version = var.builder_images_version
    allow_anonymous_read   = var.enable_keycloak ? "false" : "true"
    jenkins-repository-dockercfg = kubernetes_secret.jenkins_repository_dockercfg.metadata[0].name


    # Keycloak specific vars
    security_realm         = var.enable_keycloak ? "securityRealm: keycloak" : ""
    keycloak_ssl           = local.protocol == "http" ? "none" : "external"
    # keycloak_url must be accessible from both inside and outside the cluster.
    # For local environment, you'll need to add this line to your hosts file...
    # [YOUR_HOST_INTERNAL_IP_NOT_127.0.0.1]   keycloak.toolchain.docker-for-desktop.localhost
    keycloak_url           = "${local.protocol}://keycloak.toolchain.${var.cluster_domain}/auth"
  }
}

module "toolchain_namespace" {
  source    = "../../common/namespace"
  namespace = "${var.product_name}-toolchain"
  annotations = {
    name                                 = "${var.product_name}-toolchain"
    "opa.lead.liatrio/ingress-whitelist" = "*.${var.product_name}-toolchain.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist"   = var.image_whitelist
  }
  resource_request_cpu = "100m"
  resource_limit_cpu = "250m"

  providers = {
    helm       = helm.toolchain
    kubernetes = kubernetes.toolchain
  }
}

resource "helm_release" "jenkins" {
  provider  = helm.toolchain
  name      = "jenkins"
  chart     = "stable/jenkins"
  namespace = module.toolchain_namespace.name
  timeout   = "600"
  version   = "1.6.0"

  set_sensitive {
    name  = "master.adminPassword"
    value = random_string.jenkins_admin_password.result
  }

  values = [data.template_file.jenkins_values.rendered]
}

// Create Jenkins service account
resource "kubernetes_service_account" "jenkins" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Service account for Jenkins"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  automount_service_account_token = true
}

// Add role to allow Jenkins to read secrets
resource "kubernetes_role" "jenkins_kubernetes_credentials" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-kubernetes-credentials"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to read secrets"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "watch", "list"]
  }
  rule {
    api_groups = ["stable.liatr.io"]
    resources  = ["builds"]
    verbs      = ["create", "update", "patch", "get", "watch", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "get", "watch", "list"]
  }
}

// Bind Kubernetes secrets role to Jenkins service account
resource "kubernetes_role_binding" "jenkins_kubernetes_credentials" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-kubernetes-credentials"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to read secrets"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.jenkins_kubernetes_credentials.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = module.toolchain_namespace.name
  }
}

resource "kubernetes_cluster_role" "jenkins_kubernetes_credentials" {
  provider = kubernetes.toolchain
  metadata {
    name      = "${module.toolchain_namespace.name}-jenkins-kubernetes-credentials"

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to manage builds"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["create", "get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins_kubernetes_credentials" {
  provider = kubernetes.toolchain
  metadata {
    name      = "${module.toolchain_namespace.name}-jenkins-kubernetes-credentials"

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to read secrets"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins_kubernetes_credentials.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = module.toolchain_namespace.name
  }
}

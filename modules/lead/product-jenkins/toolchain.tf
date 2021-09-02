resource "random_password" "jenkins_admin_password" {
  length  = 10
  special = false
}

module "essential_tolerations" {
  source = "../../affinity/essential-toleration-values"
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
  resource_limit_cpu   = "250m"

  providers = {
    helm       = helm.toolchain
    kubernetes = kubernetes.toolchain
  }
}

resource "kubernetes_service_account" "jenkins" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Service account for Jenkins"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  automount_service_account_token = true
}

resource "helm_release" "jenkins" {
  provider   = helm.toolchain
  name       = "jenkins"
  chart      = "jenkins"
  repository = "https://charts.jenkins.io"
  namespace  = module.toolchain_namespace.name
  timeout    = "600"
  version    = "3.5.11"

  set_sensitive {
    name  = "controller.adminPassword"
    value = random_password.jenkins_admin_password.result
  }

  values = [
    templatefile("${path.module}/jenkins-values.tpl", {
      service_account_name  = kubernetes_service_account.jenkins.metadata[0].name
      toolchain_image_repo  = var.toolchain_image_repo
      jenkins_image_version = var.jenkins_image_version
      protocol              = local.protocol
      ssl_redirect          = local.protocol == "http" ? false : true
      ingress_hostname      = local.ingress_hostname
      enable_keycloak       = var.enable_keycloak
    })
  ]
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
      "app.kubernetes.io/component"  = "jenkins-controller"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to read secrets"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  rule {
    api_groups = [
      ""
    ]
    resources = [
      "secrets"
    ]
    verbs = [
      "get",
      "watch",
      "list",
    ]
  }
  rule {
    api_groups = [
      "stable.liatr.io",
      "sdm.liatr.io",
    ]
    resources = [
      "builds"
    ]
    verbs = [
      "create",
      "update",
      "patch",
      "get",
      "watch",
      "list",
    ]
  }
  rule {
    api_groups = [
      ""
    ]
    resources = [
      "events"
    ]
    verbs = [
      "create",
      "get",
      "watch",
      "list",
    ]
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
      "app.kubernetes.io/component"  = "jenkins-controller"
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
    name = "${module.toolchain_namespace.name}-jenkins-kubernetes-credentials"

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to manage builds"
      source-repo = "https://github.com/liatrio/lead-toolchain"
    }
  }

  rule {
    api_groups = [
      "apiextensions.k8s.io"
    ]
    resources = [
      "customresourcedefinitions"
    ]
    verbs = [
      "create",
      "get",
      "list",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins_kubernetes_credentials" {
  provider = kubernetes.toolchain
  metadata {
    name = "${module.toolchain_namespace.name}-jenkins-kubernetes-credentials"

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
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

resource "kubernetes_role_binding" "jenkins_staging_rolebinding" {
  provider = kubernetes.staging
  metadata {
    name      = "jenkins-staging-rolebinding"
    namespace = module.product_base.staging_namespace

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' to get pods in staging namespace"
      source-repo = "https://github.com/liatrio/lead-terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = module.product_base.ci_staging_role_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = module.toolchain_namespace.name
  }
}

resource "kubernetes_role_binding" "jenkins_production_rolebinding" {
  provider = kubernetes.production
  metadata {
    name      = "jenkins-production-rolebinding"
    namespace = module.product_base.production_namespace

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
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
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = module.toolchain_namespace.name
  }
}

resource "kubernetes_config_map" "jcasc_pipelines_configmap" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-casc"
    namespace = module.toolchain_namespace.name

    labels = {
      "jenkins-jenkins-config" = "true"
    }
  }
  data = {
    "jobs.yaml" = trim(replace(jsonencode(replace(trimspace(templatefile("${path.module}/pipelines-${var.jenkins_pipeline_source}.tpl", {
      pipelines             = var.pipelines
      github_credentials_id = var.jenkins_pipeline_source == "github" ? kubernetes_secret.github[0].metadata[0].name : ""
    })), "/,]}$/", "]}")), "/\\\\\"/", "\""), "\"")
  }
}

resource "kubernetes_config_map" "jcasc_shared_libraries_configmap" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-jenkins-config-shared-libraries"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins-jenkins-config"       = "true"
    }
  }
  data = {
    "shared-libraries.yaml" = templatefile("${path.module}/shared-libraries.tpl", {})
  }
}

resource "kubernetes_config_map" "jcasc_pod_templates_configmap" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-jenkins-config-pod-templates"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins-jenkins-config"       = "true"
    }
  }
  data = {
    "pod-templates.yaml" = templatefile("${path.module}/pod-templates.tpl", {
      essential_tolerations  = module.essential_tolerations.values
      namespace              = module.toolchain_namespace.name
      dockercfg_secret_name  = kubernetes_secret.jenkins_repository_dockercfg.metadata[0].name
      toolchain_image_repo   = var.toolchain_image_repo
      product_image_repo     = var.product_image_repo
      product_name           = var.product_name
      builder_images_version = var.builder_images_version
    })
  }
}

resource "kubernetes_config_map" "jcasc_env_configmap" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-jenkins-config-env"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
      "app.kubernetes.io/managed-by" = "Helm"
      "helm.sh/chart"                = "jenkins-1.6.0"
      "jenkins-jenkins-config"       = "true"
    }
  }
  data = {
    "env.yaml" = templatefile("${path.module}/jenkins-env.tpl", {
      logstash_url        = "http://lead-dashboard-logstash.toolchain.svc.cluster.local:9000"
      stagingNamespace    = module.product_base.staging_namespace
      productionNamespace = module.product_base.production_namespace
      databaseNamespace   = module.product_base.database_namespace
      toolchain_namespace = var.toolchain_namespace
      appDomain           = "apps.${var.cluster_domain}"
      product_name        = var.product_name
    })
  }
}

resource "kubernetes_config_map" "jcasc_keycloak_config_configmap" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-jenkins-config-keycloak-config"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins-jenkins-config"       = "true"
    }
  }
  data = {
    "keycloak-config.yaml" = templatefile("${path.module}/keycloak-config.tpl", {
      ingress_hostname = "${module.toolchain_namespace.name}.jenkins.${var.cluster_domain}"
      keycloak_ssl     = local.protocol == "http" ? "none" : "external"
      # keycloak_url must be accessible from both inside and outside the cluster.
      # For local environment, you'll need to add this line to your hosts file...
      # [YOUR_HOST_INTERNAL_IP_NOT_127.0.0.1]   keycloak.toolchain.docker-for-desktop.localhost
      keycloak_url = "${local.protocol}://keycloak.toolchain.${var.cluster_domain}/auth"
    })
  }
}

resource "kubernetes_config_map" "jcasc_controller_configmap" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-jenkins-config-controller"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins-jenkins-config"       = "true"
    }
  }
  data = {
    "controller-node.yaml" = templatefile("${path.module}/controller.tpl", {
      root_url = "${local.protocol}://${local.ingress_hostname}"
    })
  }
}

resource "kubernetes_config_map" "jcasc_security_configmap" {
  provider = kubernetes.toolchain
  metadata {
    name      = "jenkins-jenkins-config-security-config"
    namespace = module.toolchain_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-controller"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins-jenkins-config"       = "true"
    }
  }
  data = {
    "security-config.yaml" = templatefile("${path.module}/security-config.tpl", {
      enable_keycloak = var.enable_keycloak
    })
  }
}

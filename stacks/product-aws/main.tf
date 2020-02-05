
terraform {
  backend "s3" {}
}

provider "kubernetes" {
  alias            = "toolchain"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  alias           = "toolchain"
  version         = "0.10.4"
  namespace       = module.product.toolchain_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.product.toolchain_service_account

  override = [
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key=kubernetes.io/lifecycle",
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator=NotIn",
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]=preemptible",
    "spec.template.spec.tolerations[0].key=${var.essential_taint_key}",
    "spec.template.spec.tolerations[0].operator=Exists",
    "spec.template.spec.containers[0].resources.limits.memory=400Mi",
    "spec.template.spec.containers[0].resources.requests.memory=100Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=800m",
    "spec.template.spec.containers[0].resources.requests.cpu=100m",
  ]

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

provider "kubernetes" {
  alias            = "staging"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  alias           = "staging"
  version         = "0.10.4"
  namespace       = module.product.staging_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.product.staging_service_account

  override = [
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key=kubernetes.io/lifecycle",
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator=NotIn",
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]=preemptible",
    "spec.template.spec.tolerations[0].key=${var.essential_taint_key}",
    "spec.template.spec.tolerations[0].operator=Exists",
    "spec.template.spec.containers[0].resources.limits.memory=400Mi",
    "spec.template.spec.containers[0].resources.requests.memory=100Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=800m",
    "spec.template.spec.containers[0].resources.requests.cpu=100m",
  ]

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

provider "kubernetes" {
  alias            = "production"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  alias           = "production"
  version         = "0.10.4"
  namespace       = module.product.production_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.product.production_service_account

  override = [
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key=kubernetes.io/lifecycle",
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator=NotIn",
    "spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]=preemptible",
    "spec.template.spec.tolerations[0].key=${var.essential_taint_key}",
    "spec.template.spec.tolerations[0].operator=Exists",
    "spec.template.spec.containers[0].resources.limits.memory=400Mi",
    "spec.template.spec.containers[0].resources.requests.memory=100Mi",
    "spec.template.spec.containers[0].resources.limits.cpu=800m",
    "spec.template.spec.containers[0].resources.requests.cpu=100m",
  ]

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

provider "kubernetes" {
  alias            = "system"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "helm" {
  alias           = "system"
  version         = "0.10.4"
  namespace       = "lead-system"
  install_tiller  = false

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

module "product" {
  source                  = "../../modules/lead/product"
  cluster_domain          = var.cluster_domain
  product_name            = var.product_name
  image_whitelist         = var.image_whitelist
  enable_keycloak         = var.enable_keycloak
  enable_istio            = var.enable_istio
  enable_harbor           = var.enable_harbor
  builder_images_version  = var.builder_images_version
  jenkins_image_version   = var.jenkins_image_version
  toolchain_image_repo    = var.toolchain_image_repo
  product_image_repo      = var.product_image_repo

  providers = {
    kubernetes.toolchain  = kubernetes.toolchain
    helm.toolchain        = helm.toolchain
    kubernetes.staging    = kubernetes.staging
    helm.staging          = helm.staging
    kubernetes.production = kubernetes.production
    helm.production       = helm.production
    kubernetes.system     = kubernetes.system
    helm.system           = helm.system
  }
}

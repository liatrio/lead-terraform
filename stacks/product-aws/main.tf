
terraform {
  backend "s3" {}
}

provider "kubernetes" {
  alias            = "staging"
  load_config_file = var.load_config_file
  config_context   = var.config_context
}

provider "aws" {
  version = ">= 2.29.0"
  region  = var.region
}

provider "helm" {
  alias           = "staging"
  version         = "0.10.4"
  namespace       = module.product_jenkins.staging_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.product_jenkins.staging_service_account

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
    "spec.template.metadata.annotations.sidecar\\.istio\\.io/inject=false",
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
  namespace       = module.product_jenkins.production_namespace
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.15.1"
  service_account = module.product_jenkins.production_service_account

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
    "spec.template.metadata.annotations.sidecar\\.istio\\.io/inject=false",
  ]

  kubernetes {
    load_config_file = var.load_config_file
    config_context   = var.config_context
  }
}

module "product-aws" {
  source                  = "../../modules/lead/product-aws"
  cluster_domain          = var.cluster_domain
  product_name            = var.product_name
  image_whitelist         = var.image_whitelist
  providers = {
    kubernetes.staging    = kubernetes.staging
    helm.staging          = helm.staging
    kubernetes.production = kubernetes.production
    helm.production       = helm.production
    aws                   = aws
  }
}

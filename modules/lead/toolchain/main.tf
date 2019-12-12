locals {
  protocol = var.root_zone_name == "localhost" ? "http" : "https"
}

provider "helm" {
}

provider "helm" {
  alias = "system"
}

provider "kubernetes" {
}

data "helm_repository" "codecentric" {
  name = "codecentric"
  url  = "https://codecentric.github.io/helm-charts"
}

data "helm_repository" "liatrio" {
  name = "liatrio"
  url  = "https://artifactory.liatr.io/artifactory/helm/"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

module "toolchain_namespace" {
  source    = "../../common/namespace"
  namespace = var.namespace
  annotations = {
    name                                         = var.namespace
    cluster                                      = var.cluster
    "opa.lead.liatrio/ingress-whitelist"         = "*.${var.namespace}.${var.cluster}.${var.root_zone_name}"
    "opa.lead.liatrio/image-whitelist"           = var.image_whitelist
    "opa.lead.liatrio/elb-extra-security-groups" = var.elb_security_group_id
  }
}

module "toolchain_certificate" {
  source          = "../../common/certificates"
  namespace       = "istio-system"
  name            = module.toolchain_namespace.name
  domain          = "${module.toolchain_namespace.name}.${var.cluster_domain}"
  enabled         = var.enable_istio
  certificate_crd = "set"

  providers = {
    helm       = helm.system
    kubernetes = kubernetes
  }
}

module "toolchain_ingress" {
  source                          = "../../common/nginx-ingress"
  namespace                       = module.toolchain_namespace.name
  ingress_controller_type         = var.ingress_controller_type
  ingress_external_traffic_policy = var.ingress_external_traffic_policy
}

module "toolchain_issuer" {
  source        = "../../common/cert-issuer"
  namespace     = module.toolchain_namespace.name
  issuer_type   = var.issuer_type
  issuer_server = "https://acme-v02.api.letsencrypt.org/directory"
  crd_waiter    = var.crd_waiter

  // variables below are only relevant if var.issuer_type == "acme"
  acme_solver                 = "http"
  provider_http_ingress_class = "nginx"
}

resource "kubernetes_cluster_role" "tiller_cluster_role" {
  metadata {
    name = "toolchain-tiller-manager"
  }
  rule {
    api_groups = ["", "batch", "extensions", "apps", "stable.liatr.io", "policy", "apiextensions.k8s.io", "services/proxy"]
    resources  = ["*"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs      = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses", "ingresses/status", "networkpolicies"]
    verbs      = ["get", "create", "update", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["cert-manager.io", "certmanager.k8s.io"]
    resources  = ["issuers", "certificates"]
    verbs      = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["appmesh.k8s.aws"]
    resources  = ["meshes", "meshes/status", "virtualnodes", "virtualnodes/status", "virtualservices", "virtualservices/status"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["flagger.app"]
    resources  = ["canaries", "canaries/status"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["gateway.solo.io"]
    resources  = ["gateways", "virtualservices"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["gloo.solo.io"]
    resources  = ["proxies", "settings", "upstreamgroups", "upstreams", "virtualservices"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["split.smi-spec.io"]
    resources  = ["trafficsplits"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["networking.istio.io"]
    resources  = ["*"]
    verbs      = ["list", "watch", "create", "patch", "get", "delete"]
  }
  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["nodes", "pods"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["validatingwebhookconfigurations", "mutatingwebhookconfigurations"]
    verbs      = ["get", "update", "create"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["podsecuritypolicies"]
    verbs      = ["use"]
  }
  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = ["monitoring.coreos.com"]
    resources  = ["alertmanagers", "alertmanagers/finalizers", "podmonitors", "prometheuses", "prometheuses/finalizers", "prometheusrules", "servicemonitors"]
    verbs      = ["*"]
  }
  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "tiller_cluster_role_binding" {
  metadata {
    name = "toolchain-tiller-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.tiller_cluster_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = module.toolchain_namespace.name
  }
}

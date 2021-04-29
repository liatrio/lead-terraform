resource "kubernetes_cluster_role" "nginx_ingress_cluster_role" {
  metadata {
    name      = "nginx-ingress-manager"
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch", "update"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["ingress-controller-leader-nginx"]
    verbs          = ["get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "create", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["create", "get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }
}

// Ingress controller for each product's Jenkins instance

resource "kubernetes_service_account" "jenkins_nginx_ingress_service_account" {
  metadata {
    name      = "jenkins-nginx-ingress"
    namespace =  var.namespace
  }
  automount_service_account_token = true
}

// ClusterRoleBinding is used here because this ingress controller will service multiple namespaces
resource "kubernetes_cluster_role_binding" "jenkins_nginx_ingress_role_binding" {
  metadata {
    name      = "jenkins-nginx-ingress-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.nginx_ingress_cluster_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins_nginx_ingress_service_account.metadata[0].name
    namespace = kubernetes_service_account.jenkins_nginx_ingress_service_account.metadata[0].namespace
  }
}

module "jenkins_wildcard" {
  source = "../../common/certificates"

  name      = "jenkins-wildcard"
  namespace = var.namespace
  domain    = "jenkins.${var.cluster_domain}"
  enabled   = true

  issuer_name = var.issuer_name
  issuer_kind = var.issuer_kind
}

module "jenkins_ingress" {
  source                          = "../../common/nginx-ingress"
  namespace                       = var.namespace
  name                            = "jenkins"
  ingress_controller_type         = var.ingress_controller_type
  ingress_external_traffic_policy = var.ingress_external_traffic_policy
  ingress_class                   = "jenkins-nginx"
  service_account                 = kubernetes_service_account.jenkins_nginx_ingress_service_account.metadata[0].name
  cluster_wide                    = true
  default_certificate             = "${var.namespace}/${module.jenkins_wildcard.cert_secret_name}"
}

// Ingress controller for toolchain namespace

resource "kubernetes_service_account" "toolchain_nginx_ingress_service_account" {
  metadata {
    name      = "toolchain-nginx-ingress"
    namespace =  var.namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "toolchain_nginx_ingress_role_binding" {
  metadata {
    name      = "toolchain-nginx-ingress-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.nginx_ingress_cluster_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.toolchain_nginx_ingress_service_account.metadata[0].name
    namespace = kubernetes_service_account.toolchain_nginx_ingress_service_account.metadata[0].namespace
  }
}

module "toolchain_wildcard" {
  source = "../../common/certificates"

  name      = "toolchain-wildcard"
  namespace = var.namespace
  domain    = "toolchain.${var.cluster_domain}"
  enabled   = true

  issuer_name = var.issuer_name
  issuer_kind = var.issuer_kind
}

module "toolchain_ingress" {
  source                          = "../../common/nginx-ingress"
  namespace                       = var.namespace
  name                            = "toolchain"
  ingress_controller_type         = var.ingress_controller_type
  ingress_external_traffic_policy = var.ingress_external_traffic_policy
  ingress_class                   = "toolchain-nginx"
  service_account                 = kubernetes_service_account.toolchain_nginx_ingress_service_account.metadata[0].name
  cluster_wide                    = true
  default_certificate             = "${var.namespace}/${module.toolchain_wildcard.cert_secret_name}"
}

// Ingress controller for internal access

resource "kubernetes_service_account" "internal_nginx_ingress_service_account" {
  metadata {
    name      = "internal-nginx-ingress"
    namespace =  var.namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "internal_nginx_ingress_role_binding" {
  metadata {
    name      = "internal-nginx-ingress-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.nginx_ingress_cluster_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.internal_nginx_ingress_service_account.metadata[0].name
    namespace = kubernetes_service_account.internal_nginx_ingress_service_account.metadata[0].namespace
  }
}

module "internal_wildcard" {
  source = "../../common/certificates"

  name      = "internal-wildcard"
  namespace = var.namespace
  domain    = "internal.${var.cluster_domain}"
  enabled   = true

  issuer_name = var.issuer_name
  issuer_kind = var.issuer_kind
}

// Ingress for strictly allowing only Internal VPN traffic
module "internal_ingress" {
  source                          = "../../common/nginx-ingress"
  namespace                       = var.namespace
  name                            = "internal"
  ingress_controller_type         = var.ingress_controller_type
  ingress_external_traffic_policy = var.ingress_external_traffic_policy
  ingress_class                   = "internal-nginx"
  service_annotaitons = {
    "service.beta.kubernetes.io/aws-load-balancer-internal": "10.1.32.0/20" # Internal VPN Subnet
  }
  service_account                 = kubernetes_service_account.internal_nginx_ingress_service_account.metadata[0].name
  cluster_wide                    = true
  default_certificate             = "${var.namespace}/${module.internal_wildcard.cert_secret_name}"
}

resource "kubernetes_role" "nginx_ingress_role" {
  metadata {
    name      = "nginx-ingress-manager"
    namespace = var.namespace
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
    verbs      = ["create"]
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

// The ClusterRole has the same permissions as the role above, but must also be created so it can be used with a ClusterRoleBinding
resource "kubernetes_cluster_role" "nginx_ingress_cluster_role" {
  metadata {
    name      = "nginx-ingress-manager"
    namespace = var.namespace
  }

  dynamic "rule" {
    for_each = kubernetes_role.nginx_ingress_role.rule

    content {
      api_groups = rule.value.api_groups
      resources = rule.value.resources
      verbs = rule.value.verbs
    }
  }
}

// Ingress controller for each product's Jenkins instance

resource "kubernetes_service_account" "jenkins_nginx_ingress_service_account" {
  metadata {
    name      = "jenkins-nginx-ingress"
    namespace = var.namespace
  }
  automount_service_account_token = true
}

// ClusterRoleBinding is used here because this ingress controller will service multiple namespaces
resource "kubernetes_cluster_role_binding" "jenkins_nginx_ingress_role_binding" {
  metadata {
    name      = "jenkins-nginx-ingress-binding"
    namespace = var.namespace
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
  namespace = module.toolchain_namespace.name
  domain    = "jenkins.${var.cluster_domain}"
  enabled   = true

  issuer_name = var.issuer_name
  issuer_kind = var.issuer_kind

  certificate_crd = var.crd_waiter
}

module "jenkins_ingress" {
  source                          = "../../common/nginx-ingress"
  namespace                       = module.toolchain_namespace.name
  name                            = "jenkins"
  ingress_controller_type         = var.ingress_controller_type
  ingress_external_traffic_policy = var.ingress_external_traffic_policy
  ingress_class                   = "jenkins-nginx"
  service_account                 = kubernetes_service_account.jenkins_nginx_ingress_service_account.metadata[0].name
  cluster_wide                    = true
  default_certificate             = module.jenkins_wildcard.cert_secret_name
}

// Ingress controller for toolchain namespace

resource "kubernetes_service_account" "toolchain_nginx_ingress_service_account" {
  metadata {
    name      = "toolchain-nginx-ingress"
    namespace = var.namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_role_binding" "toolchain_nginx_ingress_role_binding" {
  metadata {
    name      = "toolchain-nginx-ingress-binding"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.nginx_ingress_role.metadata[0].name
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
  namespace = module.toolchain_namespace.name
  domain    = "toolchain.${var.cluster_domain}"
  enabled   = true

  issuer_name = var.issuer_name
  issuer_kind = var.issuer_kind

  certificate_crd = var.crd_waiter
}

module "toolchain_ingress" {
  source                          = "../../common/nginx-ingress"
  namespace                       = module.toolchain_namespace.name
  name                            = "toolchain"
  ingress_controller_type         = var.ingress_controller_type
  ingress_external_traffic_policy = var.ingress_external_traffic_policy
  ingress_class                   = "toolchain-nginx"
  service_account                 = kubernetes_service_account.jenkins_nginx_ingress_service_account.metadata[0].name
  cluster_wide                    = false
  default_certificate             = module.toolchain_certificate.cert_secret_name
}

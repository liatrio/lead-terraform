data "template_file" "nginx_ingress_values" {
  template = "${file("${path.module}/nginx-ingress-values.tpl")}"

  vars = {
    ingress_controller_type = "${var.ingress_controller_type}"
    service_account = "${kubernetes_service_account.nginx_ingress_service_account.metadata.0.name}"
  }
}

data "helm_repository" "stable" {
  provider  = "helm.toolchain"
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "nginx_ingress" {
  provider  = "helm.toolchain"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "nginx-ingress"
  version    = "1.4.0"
  namespace  = "${module.toolchain_namespace.name}"
  name       = "nginx-ingress"
  timeout    = 600

  values = ["${data.template_file.nginx_ingress_values.rendered}"]
}

resource "kubernetes_service_account" "nginx_ingress_service_account" {
  provider  = "kubernetes.toolchain"
  metadata {
    name = "nginx-ingress"
    namespace  = "${module.toolchain_namespace.name}"
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "nginx_ingress_role" {
  provider  = "kubernetes.toolchain"
  metadata {
    name = "${module.toolchain_namespace.name}-nginx-ingress-manager"
  }
  rule {
    api_groups = [""]
    resources = ["nodes"]
    verbs = ["get","list","watch"]
  }
}

resource "kubernetes_cluster_role_binding" "nginx_ingress_role_binding" {
  provider  = "kubernetes.toolchain"
  metadata {
    name = "${module.toolchain_namespace.name}-nginx-ingress-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${kubernetes_cluster_role.nginx_ingress_role.metadata.0.name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.nginx_ingress_service_account.metadata.0.name}"
    namespace  = "${module.toolchain_namespace.name}"
  }
}

resource "kubernetes_role" "nginx_ingress_role" {
  provider  = "kubernetes.toolchain"
  metadata {
    name = "nginx-ingress-manager"
    namespace  = "${module.toolchain_namespace.name}"
  }
  rule {
    api_groups = [""]
    resources = ["namespaces"]
    verbs = ["get"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps","pods","secrets","endpoints"]
    verbs = ["get","list","watch"]
  }
  rule {
    api_groups = [""]
    resources = ["services"]
    verbs = ["get","list","watch","update"]
  }
  rule {
    api_groups = ["extensions"]
    resources = ["ingresses"]
    verbs = ["get","list","watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources = ["ingresses/status"]
    verbs = ["update"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps"]
    resource_names = ["ingress-controller-leader-nginx"]
    verbs = ["get","update"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps"]
    verbs = ["create"]
  }
  rule {
    api_groups = [""]
    resources = ["endpoints"]
    verbs = ["create","get","update"]
  }
  rule {
    api_groups = [""]
    resources = ["events"]
    verbs = ["create","patch"]
  }
}

resource "kubernetes_role_binding" "nginx_ingress_role_binding" {
  provider  = "kubernetes.toolchain"
  metadata {
    name = "nginx-ingress-binding"
    namespace  = "${module.toolchain_namespace.name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${kubernetes_role.nginx_ingress_role.metadata.0.name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.nginx_ingress_service_account.metadata.0.name}"
    namespace  = "${module.toolchain_namespace.name}"
  }
}

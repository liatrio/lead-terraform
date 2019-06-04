data "template_file" "opa_values" {
  count = "${ var.enable_opa ? 1 : 0 }"
  template = "${file("${path.module}/opa-values.tpl")}"

  vars = {
    namespace  = "${var.namespace}"
    service_account = "${kubernetes_service_account.opa_service_account.metadata.0.name}"
    failure_policy = "${var.opa_failure_policy}"
  }
}
resource "helm_release" "opa" {
  count = "${ var.enable_opa ? 1 : 0 }"
  repository = "stable"
  name       = "opa"
  namespace  = "${var.namespace}"
  chart      = "opa"
  version    = "1.4.3"
  timeout    = 900
  recreate_pods = true

  values = ["${data.template_file.opa_values.rendered}"]
}

resource "kubernetes_config_map" "opa-default-system-main" {
  count = "${ var.enable_opa ? 1 : 0 }"
  metadata {
    name = "opa-default-system-main"
    namespace  = "${var.namespace}"
    labels {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data {
    main = "${file("${path.module}/policies/main.rego")}"
    image_provenance = "${file("${path.module}/policies/image_provenance.rego")}"
    ingress_whitelist = "${file("${path.module}/policies/ingress_whitelist.rego")}"
    service_constraint = "${file("${path.module}/policies/service_constraint.rego")}"
  }
}

resource "kubernetes_service_account" "opa_service_account" {
  count = "${ var.enable_opa ? 1 : 0 }"
  metadata {
    name = "opa"
    namespace  = "${var.namespace}"
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "opa_role" {
  count = "${ var.enable_opa ? 1 : 0 }"
  metadata {
    name = "opa-manager"
  }
  rule {
    api_groups = [""]
    resources = ["namespaces"]
    verbs = ["get","list","watch"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps"]
    verbs = ["get","list","watch","patch","update"]
  }
}

resource "kubernetes_cluster_role_binding" "opa_role_binding" {
  count = "${ var.enable_opa ? 1 : 0 }"
  metadata {
    name = "opa-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${kubernetes_cluster_role.opa_role.metadata.0.name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.opa_service_account.metadata.0.name}"
    namespace  = "${var.namespace}"
  }
}

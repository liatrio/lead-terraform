module "system_namespace" {
  source     = "../../common/namespace"
  namespace  = "${var.namespace}"
  annotations {
    name = "${var.namespace}"
    cluster = "${var.cluster}"
  }
  labels {
    "openpolicyagent.org/webhook" = "ignore"
    "certmanager.k8s.io/disable-validation" = "true"
  }
}
module "system_issuer" {
  source = "../../common/cert-issuer"
  namespace  = "${module.system_namespace.name}"
  issuer_type = "${var.issuer_type}"
  crd_waiter = "${null_resource.cert_manager_crd_delay.id}"
}


resource "kubernetes_cluster_role" "tiller_cluster_role" {
  metadata {
    name = "lead-system-tiller-cluster-manager"
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["storageclasses"]
    verbs = ["watch","list","get"]
  }
  rule {
    api_groups = ["admissionregistration.k8s.io"]
    resources = ["validatingwebhookconfigurations","mutatingwebhookconfigurations"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources = ["customresourcedefinitions"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources = ["clusterroles", "clusterrolebindings", "roles", "rolebindings"]
    verbs = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["apiregistration.k8s.io"]
    resources = ["apiservices"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["authorization.k8s.io"]
    resources = ["selfsubjectaccessreviews","selfsubjectrulesreviews"]
    verbs = ["create"]
  }
  rule {
    api_groups = ["admission.certmanager.k8s.io"]
    resources = ["certificates","issuers","clusterissuers"]
    verbs = ["get", "create", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["certificates.k8s.io"]
    resources = ["certificatesigningrequests"]
    verbs = ["list","watch"]
  }
  rule {
    api_groups = ["certmanager.k8s.io"]
    resources = ["certificates","certificates/finalizers","issuers","clusterissuers","orders","orders/finalizers","challenges"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["authentication.k8s.io"]
    resources = ["tokenreviews"]
    verbs = ["create"]
  }
  rule {
    api_groups = ["authorization.k8s.io"]
    resources = ["subjectaccessreviews"]
    verbs = ["create"]
  }
  rule {
    api_groups = ["policy"]
    resources = ["poddisruptionbudgets"]
    verbs = ["*"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps","events","secrets","services","serviceaccounts","pods","pods/logs","pods/eviction","pods/status"]
    verbs = ["*"]
  }
  rule {
    api_groups = [""]
    resources = ["namespaces","nodes","limitranges","persistentvolumeclaims","persistentvolumes","resourcequotas","ingresses"]
    verbs = ["get","list","watch","update"]
  }
  rule {
    api_groups = [""]
    resources = ["nodes/stats"]
    verbs = ["get","create"]
  }
  rule {
    api_groups = ["extensions"]
    resources = ["ingresses"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["autoscaling"]
    resources = ["horizontalpodautoscalers"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["authentication.istio.io"]
    resources = ["*"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["config.istio.io"]
    resources = ["*"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["networking.istio.io"]
    resources = ["*"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["rbac.istio.io"]
    resources = ["*"]
    verbs = ["get","list","watch"]
  }
  rule {
    api_groups = [""]
    resources = ["endpoints"]
    verbs = ["get","list","watch","create","update","patch"]
  }
  rule {
    api_groups = ["apps"]
    resources = ["deployments"]
    resource_names = ["istio-galley"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["apps"]
    resources = ["deployments"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["extensions"]
    resources = ["deployments"]
    resource_names = ["istio-galley"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["extensions"]
    resources = ["deployments"]
    verbs = ["get","list","watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources = ["deployments/finalizers"]
    resource_names = ["istio-galley"]
    verbs = ["update"]
  }
  rule {
    api_groups = [""]
    resources = ["replicationcontrollers"]
    verbs = ["get","list","watch"]
  }
  rule {
    api_groups = ["apps"]
    resources = ["replicasets"]
    verbs = ["get","list","watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources = ["replicasets","daemonsets"]
    verbs = ["get","list","watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources = ["ingresses/status"]
    verbs = ["*"]
  }
  rule {
    api_groups = [""]
    resources = ["nodes/proxy"]
    verbs = ["get","list","watch"]
  }
  rule {
    api_groups = ["batch"]
    resources = ["jobs"]
    verbs = ["*"]
  }
  rule {
    non_resource_urls = ["/metrics"]
    verbs = ["get"]
  }
  rule {
    api_groups = ["appmesh.k8s.aws"]
    resources = ["meshes","meshes/status","virtualnodes","virtualnodes/status","virtualservices","virtualservices/status"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["flagger.app"]
    resources = ["canaries","canaries/status"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["gateway.solo.io"]
    resources = ["gateways","virtualservices"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["gloo.solo.io"]
    resources = ["proxies","settings","upstreamgroups","upstreams","virtualservices"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["split.smi-spec.io"]
    resources = ["trafficsplits"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["apps"]
    resources = ["statefulsets", "daemonsets"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["extensions"]
    resources = ["statefulsets"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["monitoring.kiali.io"]
    resources = ["monitoringdashboards"]
    verbs = ["get","list"]
  }
  rule {
    api_groups = ["batch"],
    resources = ["cronjobs"],
    verbs = ["get","list","watch"]
  }
  rule {
    api_groups = ["rbac.istio.io"],
    resources = ["clusterrbacconfigs"],
    verbs = ["create","delete","patch"]
  }
  rule {
    api_groups = ["rbac.istio.io"],
    resources = ["rbacconfigs"],
    verbs = ["create","delete","patch"]
  }
  rule {
    api_groups = ["rbac.istio.io"],
    resources = ["servicerolebindings"],
    verbs = ["create","delete","patch"]
  }
  rule {
    api_groups = ["rbac.istio.io"],
    resources = ["serviceroles"],
    verbs = ["create","delete","patch"]
  }
  rule {
    api_groups = [""]
    resources = ["pods/log"]
    verbs = ["get","list","watch"]
  }
}


resource "kubernetes_cluster_role_binding" "tiller_cluster_role_binding" {
  metadata {
    name = "lead-system-tiller-cluster-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${kubernetes_cluster_role.tiller_cluster_role.metadata.0.name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${module.system_namespace.tiller_service_account}"
    namespace = "${module.system_namespace.name}"
  }
}

module "opa" {
  enable_opa = "${var.enable_opa}"
  source    = "../../common/opa"
  namespace = "${module.system_namespace.name}"
  opa_failure_policy = "${var.opa_failure_policy}"
}

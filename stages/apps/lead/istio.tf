resource "helm_release" "istio_init" {
  count      = var.enable_istio ? 1 : 0
  repository = "https://storage.googleapis.com/istio-release/releases/1.4.8/charts/"
  chart      = "istio-init"
  namespace  = module.system_namespace.name
  name       = "istio-init"
  timeout    = 600
  wait       = true
  version    = "1.4.8"
}

# Give the CRD a chance to settle
resource "null_resource" "istio_init_delay" {
  provisioner "local-exec" {
    command = "sleep 15"
  }
  depends_on = [
    helm_release.istio_init
  ]
}

module "istio_system" {
  count = var.enable_istio ? 1 : 0

  source              = "../../../modules/common/istio"
  namespace           = "istio-system"
  cluster_domain      = "${var.cluster_name}.${var.root_zone_name}"
  toolchain_namespace = var.toolchain_namespace
  issuer_name         = module.cluster_issuer.issuer_name
  issuer_kind         = module.cluster_issuer.issuer_kind

  flagger_event_webhook = "http://operator-slack.${var.toolchain_namespace}.svc.cluster.local:3000/canary-events"
  k8s_storage_class     = var.k8s_storage_class

  ingress_class                 = module.toolchain_ingress.toolchain_ingress_class
  jaeger_elasticsearch_host     = module.elasticsearch.elasticsearch_host
  jaeger_elasticsearch_username = module.elasticsearch.elasticsearch_username
  jaeger_elasticsearch_password = module.elasticsearch.elasticsearch_password

  depends_on = [
    null_resource.istio_init_delay,
    helm_release.operator_toolchain
  ]
}

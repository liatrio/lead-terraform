data "helm_repository" "istio" {
  name = "istio.io"
  url  = "https://storage.googleapis.com/istio-release/releases/1.4.8/charts/"
}

resource "helm_release" "istio_init" {
  count      = var.enable_istio ? 1 : 0
  repository = data.helm_repository.istio.metadata[0].name
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
  source              = "../../modules/common/istio"
  enabled             = var.enable_istio
  namespace           = "istio-system"
  crd_waiter          = null_resource.istio_init_delay.id
  cluster_domain      = "${var.cluster}.${var.root_zone_name}"
  toolchain_namespace = var.toolchain_namespace
  issuer_name         = module.cluster_issuer.issuer_name
  issuer_kind         = module.cluster_issuer.issuer_kind

  flagger_event_webhook = "${module.sdm.slack_operator_in_cluster_url}/canary-events"
  k8s_storage_class     = var.k8s_storage_class

  ingress_class                 = module.toolchain_ingress.toolchain_ingress_class
  jaeger_elasticsearch_host     = module.elasticsearch.elasticsearch_host
  jaeger_elasticsearch_username = module.elasticsearch.elasticsearch_username
  jaeger_elasticsearch_password = module.elasticsearch.elasticsearch_password
}

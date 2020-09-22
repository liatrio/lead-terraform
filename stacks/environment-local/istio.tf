resource "helm_release" "istio_init" {
  count      = var.enable_istio ? 1 : 0
  repository = "https://storage.googleapis.com/istio-release/releases/1.4.2/charts/"
  chart      = "istio-init"
  namespace  = module.infrastructure.namespace
  name       = "istio-init"
  timeout    = 600
  wait       = true
  version    = "1.4.2"
}

# Give the CRD a chance to settle
resource "null_resource" "istio_init_delay" {
  provisioner "local-exec" {
    command = "sleep 15"
  }
  depends_on = [helm_release.istio_init]
}

module "istio_system" {
  source                = "../../modules/common/istio"
  enabled               = var.enable_istio
  namespace             = "istio-system"
  toolchain_namespace   = module.toolchain.namespace
  cluster_domain        = "${var.cluster}.${var.root_zone_name}"
  issuer_name           = module.staging_cluster_issuer.issuer_name
  issuer_kind           = module.staging_cluster_issuer.issuer_kind
  flagger_event_webhook = "${module.sdm.slack_operator_in_cluster_url}/canary-events"
  k8s_storage_class     = var.k8s_storage_class
  crd_waiter            = null_resource.istio_init_delay.id
}


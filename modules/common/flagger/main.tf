# Create CRDs for flagger
resource "helm_release" "flagger_crds" {
  count     = var.enable ? 1 : 0
  name      = "flagger-crds"
  namespace = var.namespace
  chart     = "${path.module}/helm/flagger-crds"
  timeout   = 600
  wait      = true
}

# Give the CRD a chance to settle
resource "null_resource" "flagger_crd_delay" {
  count = var.enable ? 1 : 0
  provisioner "local-exec" {
    command = "sleep 15"
  }
  depends_on = [helm_release.flagger_crds]
}

resource "helm_release" "flagger" {
  count      = var.enable ? 1 : 0
  repository = "https://flagger.app"
  chart      = "flagger"
  namespace  = var.namespace
  name       = "flagger"
  timeout    = 600
  wait       = true
  version    = "0.22.0"

  values = [templatefile("${path.module}/flagger-values.tpl", {
    mesh_provider  = var.mesh_provider
    metrics_server = var.metrics_url
    event_webhook  = var.event_webhook
    crd_create     = false
  })]
  depends_on = [null_resource.flagger_crd_delay]
}


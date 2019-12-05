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

data "helm_repository" "flagger" {
  count = var.enable ? 1 : 0
  name  = "flagger.app"
  url   = "https://flagger.app"
}

data "template_file" "flagger_values" {
  template = file("${path.module}/flagger-values.tpl")
}

resource "helm_release" "flagger" {
  count      = var.enable ? 1 : 0
  repository = data.helm_repository.flagger[0].metadata[0].name
  chart      = "flagger"
  namespace  = var.namespace
  name       = "flagger"
  timeout    = 600
  wait       = true
  version    = "0.20.4"

  set {
    name  = "meshProvider"
    value = var.mesh_provider
  }

  set {
    name  = "metricsServer"
    value = var.metrics_url
  }

  set {
    name  = "crd.create"
    value = false
  }

  values = [data.template_file.flagger_values.rendered]
  depends_on = [null_resource.flagger_crd_delay]
}


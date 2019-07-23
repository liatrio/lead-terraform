data "template_file" "flagger_values" {
  template = file("${path.module}/flagger-values.tpl")

  vars = {
    domain = var.domain
  }
}

data "helm_repository" "flagger" {
  name = "flagger"
  url  = "https://flagger.app"
}

resource "helm_release" "flagger" {
  depends_on = [helm_release.istio]
  repository = data.helm_repository.flagger.metadata[0].name
  name       = "flagger"
  chart      = "flagger/flagger"
  timeout    = 1200

  set {
    name  = "namespace"
    value = module.istio_namespace.name
  }

  set {
    name  = "meshProvider"
    value = "istio"
  }

  values = [data.template_file.flagger_values.rendered]
}

module "istio_namespace" {
  source     = "../../common/namespace"
  namespace  = "istio-system"
  annotations {
    name  = "istio-system"
    "opa.lead.liatrio/ingress-whitelist" = "*.istio-system.${var.cluster_domain}"
    "opa.lead.liatrio/image-whitelist" = "${var.image_whitelist}"
  }
  providers {
    helm = "helm.staging"
    kubernetes = "kubernetes.staging"
  }
}

data "helm_repository" "istio" {
  name = "istio"
  url  = "https://storage.googleapis.com/istio-release/releases/1.2.0/charts/"
}


resource "helm_release" "istio_init" {
  repository = "${data.helm_repository.istio.metadata.0.name}"
  chart      = "istio-init"
  namespace  = "${module.istio_namespace.name}"
  name       = "istio-init"
  timeout    = 600
  wait       = true
}

resource "helm_release" "istio" {
  repository = "${data.helm_repository.istio.metadata.0.name}"
  chart      = "istio"
  namespace  = "${module.istio_namespace.name}"
  name       = "istio"
  timeout    = 600
  wait       = true
  
  depends_on = ["helm_release.istio_init"]
}

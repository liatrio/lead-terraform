data "helm_repository" "istio" {
    name = "istio.io"
    url  = "https://storage.googleapis.com/istio-release/releases/1.2.0/charts/"
}

resource "helm_release" "istio_init" {
  repository = "${data.helm_repository.istio.metadata.0.name}"
  chart      = "istio-init"
  namespace = "${module.infrastructure.namespace}"
  name       = "istio-init"
  timeout    = 600
  wait       = true
  provider   = "helm.system"
}
# Give the CRD a chance to settle
resource "null_resource" "istio_init_delay" { 
    provisioner "local-exec" { 
        command = "sleep 15" 
    } 
    depends_on = ["helm_release.istio_init"] 
}
module "istio_system" {
  source             = "../../modules/common/istio"
  namespace          = "istio-system"
  crd_waiter         = "${null_resource.istio_init_delay.id}"
  providers {
    helm = "helm.system"
  }
}
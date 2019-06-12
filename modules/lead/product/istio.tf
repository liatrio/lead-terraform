data "helm_repository" "istio" {
    name = "istio"
    url  = "https://storage.googleapis.com/istio-release/releases/1.1.8/charts/"
}


# resource "helm_release" "istio_init" {
#   repository = "${data.helm_repository.istio.metadata.0.name}"
#   chart      = "istio-init"
#   namespace = "${var.namespace}"
#   name       = "istio-init"
#   timeout    = 600
#   wait       = true
# }
# resource "helm_release" "istio" {
#   repository = "${data.helm_repository.istio.metadata.0.name}"
#   chart      = "istio"
#   namespace = "${var.namespace}"
#   name       = "istio"
#   timeout    = 600
#   wait       = true

#   depends_on = ["helm_release.istio_init"]
# }
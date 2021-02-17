resource "helm_release" "nginx" {
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "3.23.0"
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      internal            = var.internal
      default_certificate = var.default_certificate
    })
  ]
}

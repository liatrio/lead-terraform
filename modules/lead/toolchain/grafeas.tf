resource "helm_release" "grafeas" {
  name       = "grafeas-server"
  namespace  = module.system_namespace.name
  repository = "."
  chart      = "grafeas-chart"
  version    = "0.1.0"
  timeout    = 600
  wait       = true

  depends_on = [SSL_CERTIFICATE_SECRET]

  set {
    name = "certificates.secretnam"
    value = SECRETNAME
  }

  set {
    name  = "container.port"
    value = 443 
  }
 
  set {
    name  = "certificates.enabled"
    value = "true"
  }
 
  set {
    name  = "service.port"
    value = 443 
  }

}

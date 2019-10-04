# Kube Janitor repo
data "helm_repository" "kube-janitor" {
  name = "themagicalkarp"
  url  = "https://themagicalkarp.github.io/charts"
}

resource "helm_release" "kube-janitor" {
  name       = "grafeas-server"
  namespace  = module.system_namespace.name
  repository = data.helm_repository.kube-janitor.name
  chart      = ""
  version    = "0.1.0"
  timeout    = 600
  wait       = true

  depends_on = [SSL_CERTIFICATE_SECRET]

  values     = [var.essential_toleration_values]

  set {
    secretname  = "kubejanitor.expiration"
    value = 15
  }
}

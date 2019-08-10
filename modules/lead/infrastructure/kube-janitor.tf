# Kube Janitor repo
data "helm_repository" "kube-janitor" {
  name = "themagicalkarp"
  url  = "https://themagicalkarp.github.io/charts"
}

resource "helm_release" "kube-janitor" {
  name       = "kube-janitor"
  namespace  = module.system_namespace.name
  repository = data.helm_repository.kube-janitor.name
  chart      = "themagicalkarp/kube-janitor"
  version    = "0.1.0"
  timeout    = 600
  wait       = true

  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]

  set {
    name  = "kubejanitor.expiration"
    value = 15
  }
}

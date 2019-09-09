resource "helm_release" "metrics" {
  name       = "metrics-server"
  namespace  = module.system_namespace.name
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "metrics-server"
  version    = "2.0.2"
  timeout    = 600
  wait       = true

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
  set {
    name  = "args[1]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }

  values = [var.ondemand_toleration_values]

  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]
}


output "elasticsearch_host" {
  value = "elasticsearch-master.${var.namespace}.svc.cluster.local"

  depends_on = [
    helm_release.elasticsearch
  ]
}

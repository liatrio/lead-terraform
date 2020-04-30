output "elasticsearch_host" {
  value = "elasticsearch-master.${var.namespace}.svc.cluster.local"

  depends_on = [
    helm_release.elasticsearch
  ]
}

output "elasticsearch_username" {
  value = local.elasticsearch_username

  depends_on = [
    helm_release.elasticsearch
  ]
}

output "elasticsearch_password" {
  sensitive = true
  value     = random_password.elasticsearch_password.result

  depends_on = [
    helm_release.elasticsearch
  ]
}

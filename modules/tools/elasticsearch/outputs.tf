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

output "elasticsearch_credentials_secret_name" {
  value = kubernetes_secret.elasticsearch_credentials.metadata[0].name

  depends_on = [
    helm_release.elasticsearch
  ]
}

output "elasticsearch_certificates_secret_name" {
  value = module.elasticsearch_certificate.cert_secret_name

  depends_on = [
    helm_release.elasticsearch
  ]
}

output "helm_release_name" {
  value = helm_release.elasticsearch.name
}

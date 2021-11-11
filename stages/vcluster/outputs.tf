output "cluster_host" {
  sensitive = true
  value     = local.vcluster_kubeconfig.clusters[0].cluster.server

  depends_on = [
    data.kubernetes_secret.vcluster_kubeconfig
  ]
}

output "cluster_ca_certificate" {
  sensitive = true
  value     = base64decode(local.vcluster_kubeconfig.clusters[0].cluster.certificate-authority-data)

  depends_on = [
    data.kubernetes_secret.vcluster_kubeconfig
  ]
}

output "cluster_username" {
  sensitive = true
  value     = local.vcluster_kubeconfig.users[0].name

  depends_on = [
    data.kubernetes_secret.vcluster_kubeconfig
  ]
}

output "cluster_client_certificate" {
  sensitive = true
  value     = base64decode(local.vcluster_kubeconfig.users[0].user.client-certificate-data)

  depends_on = [
    data.kubernetes_secret.vcluster_kubeconfig
  ]
}

output "cluster_client_key" {
  sensitive = true
  value     = base64decode(local.vcluster_kubeconfig.users[0].user.client-key-data)

  depends_on = [
    data.kubernetes_secret.vcluster_kubeconfig
  ]
}

output "aws_iam_openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.vcluster_openid_provider.arn
}

output "aws_iam_openid_connect_provider_url" {
  value = aws_iam_openid_connect_provider.vcluster_openid_provider.url
}

output "vcluster_api_server" {
  value = "https://${var.vcluster_apiserver_host}"
}

output "vcluster_namespace" {
  value = kubernetes_namespace.vcluster.metadata[0].name
}

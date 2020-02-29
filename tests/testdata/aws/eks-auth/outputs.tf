# output "cluster_endpoint" {
#   value = data.aws_eks_cluster.cluster.endpoint
# }

# output "cluster_certificate_authority_data" {
#   value = data.aws_eks_cluster.cluster.certificate_authority[0].data
# }

# output "cluster_token" {
#   value = data.aws_eks_cluster_auth.cluster.token
# }

output "kube_config_path" {
  value = local_file.kubeconfig.filename
}
output "cluster_id" {
  value = module.eks.cluster_id
}

output "kubeconfig" {
  value = "${path.cwd}/kubeconfig_${module.eks.cluster_id}"
}
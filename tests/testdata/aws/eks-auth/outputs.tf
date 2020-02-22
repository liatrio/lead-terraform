output "kube_config_path" {
  value = local_file.kubeconfig.filename
}
output "hostname" {
  value = local.harbor_hostname
}

output "helm_release_name" {
  value = helm_release.harbor.name
}
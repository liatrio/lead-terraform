output "namespace" {
  value = helm_release.cert_manager.namespace
}

output "status" {
  value = helm_release.cert_manager.status
}

output "helm_manifest" {
  value = helm_release.cert_manager.manifest
}

output "helm_metadata" {
  value = helm_release.cert_manager.metadata
}

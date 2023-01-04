output "cert_status" {
  value = var.enabled && length(helm_release.certificates) == 1 ? helm_release.certificates[0].status : ""
}

output "cert_name" {
  value = var.name
}

output "cert_secret_name" {
  value = "${var.name}-certificate"

  depends_on = [
    helm_release.certificates
  ]
}

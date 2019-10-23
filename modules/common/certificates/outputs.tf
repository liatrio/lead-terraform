output "cert_status" {
  value = var.enabled ? helm_release.certificates[0].status : ""
}
 
output "cert_name" {
  value = var.name
}

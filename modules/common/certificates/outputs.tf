output "cert_status" {
  value = helm_release.certificates[0].status
}
 
output "cert_name" {
  value = var.name
}

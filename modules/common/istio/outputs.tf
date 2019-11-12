output "namespace" {
  value = module.istio_namespace.name
}

output "tiller_service_account" {
  value = module.istio_namespace.tiller_service_account
}

output "cert_issuer_name" {
  value = module.istio_cert_issuer.issuer_name
}

#resource "helm_release" "cert_manager_issuers" {
#  count     = var.enabled ? 1 : 0
#  name      = "cm-${lower(var.issuer_kind)}-${var.issuer_name}"
#  namespace = var.namespace
#  chart     = "${path.module}/helm/cert-manager-issuers"
#  timeout   = 600
#  wait      = true
#  values = [templatefile("${path.module}/issuer-values.tpl", {
#    issuer_name                         = var.issuer_name
#    issuer_server                       = var.issuer_server
#    issuer_email                        = var.issuer_email
#    issuer_type                         = var.issuer_type
#    issuer_kind                         = var.issuer_kind
#    acme_solver                         = var.acme_solver
#    provider_http_ingress_class         = var.provider_http_ingress_class
#    provider_dns_type                   = var.provider_dns_type
#    route53_dns_region                  = var.route53_dns_region
#    route53_dns_hosted_zone             = var.route53_dns_hosted_zone
#    gcp_dns_project                     = var.gcp_dns_project
#    gcp_dns_service_account_secret_name = var.gcp_dns_service_account_secret_name
#    gcp_dns_service_account_secret_key  = var.gcp_dns_service_account_secret_key
#    ca_secret                           = var.ca_secret
#  })]
#}

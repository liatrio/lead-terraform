issuerName: ${issuer_name}
acme:
  enabled: ${ issuer_type == "acme" }
  server: https://acme-v02.api.letsencrypt.org/directory
  email: cloudservices@liatr.io
  httpProvider:
    enabled: ${provider_http_enabled}
    ingressClass: ${provider_http_ingress_class}
  dnsProvider:
    enabled: ${provider_dns_enabled}
    name: ${provider_dns_name}
    typeIsRoute53: ${ provider_dns_type == "route53" }
    region: ${provider_dns_region}
    hostedZoneID: ${provider_dns_hosted_zone}
selfSigned:
  enabled: ${ issuer_type == "selfSigned" }
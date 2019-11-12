issuerName: ${issuer_name}
acme:
  enabled: ${ issuer_type == "acme" }
  server: ${ issuer_server }
  email: cloudservices@liatr.io
  httpProvider:
    ingressClass: ${provider_http_ingress_class}
  dnsProvider:
    type: ${provider_dns_type}
    route53:
      region: ${route53_dns_region}
      hostedZoneID: ${route53_dns_hosted_zone}
      role: ${route53_dns_role}
  solver: ${acme_solver}
ca:
  enabled: ${issuer_type == "ca"}
  secret: ${ca_secret}
selfSigned:
  enabled: ${ issuer_type == "selfSigned" }

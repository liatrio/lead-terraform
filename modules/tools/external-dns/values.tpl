provider: ${dns_provider}
sources:
- ingress
%{~ if istio_enabled == true }
- istio-gateway
%{~ endif }
%{~ if watch_services == true }
- service
%{~ endif }
domainFilters:
${domain_filters}
%{~ if length(exclude_domains) > 0 ~}
excludeDomains:
%{ for domain in exclude_domains ~}
- ${domain}
%{~ endfor }
%{~ endif ~}
%{~ if dns_provider == "aws" }
aws:
  zoneType: ${aws_zone_type}
%{~ endif }

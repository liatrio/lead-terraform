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
%{~ if dns_provider == "aws" }
aws:
  zoneType: ${aws_zone_type}
%{~ endif }

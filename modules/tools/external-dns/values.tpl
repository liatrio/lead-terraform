provider: ${dns_provider}
sources:
- ingress
%{~ if istio_enabled == true }
- istio-gateway
%{~ endif }
domainFilters:
${domain_filters}

provider: aws
sources:
- ingress
- istio-gateway
domainFilters:
- "${domain_filter}"
extraArgs:
  istio-ingress-gateway: istio-system/istio-ingressgateway

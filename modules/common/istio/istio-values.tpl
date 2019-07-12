gateways:
  istio-egressgateway:
    enabled: false
  istio-ingressgateway:
    sds:
      enabled: true

global:
  k8sIngress:
    enabled: true
    enableHttps: true
    gatewayName: istio-ingressgateway

certmanager:
  enabled: false    
  email: cloudservices@liatr.io

grafana:
  enabled: true
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      certmanager.k8s.io/issuer: "letsencrypt-dns"
    tls:
    - hosts:
      - ${domain}
      secretName: istio-ingress-tls
    hosts:
    - ${domain}

kiali:
  enabled: true
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      certmanager.k8s.io/issuer: "letsencrypt-dns"
    tls:
    - hosts:
      - ${domain}
      secretName: istio-ingress-tls
    hosts:
    - ${domain}

tracing:
  enabled: true
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      certmanager.k8s.io/issuer: "letsencrypt-dns"
    tls:
    - hosts:
      - ${domain}
      secretName: istio-ingress-tls
    hosts:
    - ${domain}
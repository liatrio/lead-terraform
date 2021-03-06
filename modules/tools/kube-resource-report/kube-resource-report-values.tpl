updateInterval: 5
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "toolchain-nginx"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "${ssl_redirect}"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Forwarded-Proto: https";
    ingress.kubernetes.io/proxy-body-size: "0"
    ingress.kubernetes.io/proxy-read-timeout: "600"
    ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  hosts:
    - host: ${ingress_hostname}
      paths:
        - /
  tls:
  - hosts:
    - ${ingress_hostname}
resourcesApp:
  limits:
    memory: 100Mi
    cpu: 1500m
  requests:
    cpu: 100m
    memory: 50Mi

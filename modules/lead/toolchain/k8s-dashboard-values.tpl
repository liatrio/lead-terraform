ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "nginx"
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  hosts:
  - ${ingress_hostname}
  tls:
  - hosts:
    - ${ingress_hostname}
    secretName: kubernetes-dashboard-ingress-tls
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "nginx"
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    ingress.kubernetes.io/proxy-body-size: "0"
    ingress.kubernetes.io/proxy-read-timeout: "600"
    ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  hosts:
    - host: ${ingress_hostname}
      paths:
        - /
  tls:
    - secretName: mailhog-ingress-tls    
      hosts:
        - ${ingress_hostname}

  ## Allows the specification of additional environment variables
  extraEnv: |
    - name: MH_HOSTNAME
      value: "${ingress_hostname}"
    - name: MH_OUTGOING_SMTP
      value: "${smtp_json}"

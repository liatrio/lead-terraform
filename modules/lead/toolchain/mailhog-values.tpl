resources:
  requests:
    cpu: 5m
    memory: 16Mi
  limits:
    cpu: 50m
    memory: 128Mi
ingress:
  enabled: ${ingress_enabled}
  annotations:
    kubernetes.io/ingress.class: "nginx"
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
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
    - secretName: mailhog-ingress-tls    
      hosts:
        - ${ingress_hostname}

  ## Allows the specification of additional environment variables
  extraEnv: |
    - name: MH_HOSTNAME
      value: "${ingress_hostname}"


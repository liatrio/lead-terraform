ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "nginx"
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "${ssl_redirect}"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Forwarded-Proto: https";      
    ingress.kubernetes.io/proxy-body-size: "0"
    ingress.kubernetes.io/proxy-read-timeout: "600"
    ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    nginx.ingress.kubernetes.io/proxy-buffer-size: "64k"
  hosts:
  - ${ingress_hostname}
  tls:
  - hosts:
    - ${ingress_hostname}
    secretName: dashboard-keycloak-proxy-ingress-tls    
  path: /

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #  cpu: 100m
  #  memory: 128Mi
  # requests:
  #  cpu: 100m
  #  memory: 128Mi

configmap:
  targetUrl: ${dashboard_url}
  realm: ${keycloak_realm}
  realmPublicKey: ""
  authServerUrl: ${keycloak_url}
  resource: ${keycloak_client}
  secret: ${keycloak_client_secret}
  pattern: /admin
  rolesAllowed: admin  
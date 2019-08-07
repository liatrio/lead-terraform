artifactory:
  resources:
    requests:
      cpu: 75m
      memory: 2.5Gi
    limits:
      cpu: 400m
      memory: 3.5Gi
nginx:
  enabled: false
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
    nginx.ingress.kubernetes.io/configuration-snippet: |
      rewrite ^/(v2)/token /artifactory/api/docker/null/v2/token;
      rewrite ^/(v2)/([^\/]*)/(.*) /artifactory/api/docker/$2/$1/$3;
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  hosts:
  - ${ingress_hostname}
  tls:
  - hosts:
    - ${ingress_hostname}
    secretName: artifactory-ingress-tls

global:
  grafana:
    enabled: false
  hosts:
    domain: ${gitlab_fqdn}
  ingress:
    class: toolchain-nginx
    annotations:
      certmanager.k8s.io/issuer: letsencrypt-dns
    tls: 
      enabled: true
  webservice:
    resources:
      requests:
        cpu: 300m
        memory: 1.5G
      limits:
        cpu: 1
        memory: 2G
certmanager:
  install: false

certmanager-issuer:
  email: ${certmanager_issuer_email}

nginx-ingress:
  enabled: false

gitlab-runner:
  install: false
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
certmanager:
  install: false

certmanager-issuer:
  email: ${certmanager_issuer_email}

nginx-ingress:
  enabled: false

gitlab-runner:
  install: false
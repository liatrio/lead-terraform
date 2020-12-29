global:
  grafana:
    enabled: false
  hosts:
    domain: ${gitlab_fqdn}
  ingress:
    class: nginx
    tls: 
      enabled: true

certmanager:
  install: false

certmanager-issues:
  email: ${certmanager_issuer_email}

nginx-ingress:
  enabled: false

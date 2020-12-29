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

certmanager-issuer:
  email: ${certmanager_issuer_email}

nginx-ingress:
  enabled: false

gitlab-runner:
  install: true

global:
  grafana:
    enabled: false
  hosts:
    domain: ${gitlab_fqdn}
  ingress:
    class: ${ingress_class}
    annotations:
      certmanager.k8s.io/issuer: ${cert_issuer}
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
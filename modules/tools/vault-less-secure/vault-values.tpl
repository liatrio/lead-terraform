global:
  tlsDisable: true

injector:
  enabled: false

server:
  image:
    tag: ${vault_version}
  service:
    enabled: true
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: toolchain-nginx
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    hosts:
      - host: ${vault_hostname}
    tls:
      - hosts:
          - ${vault_hostname}
  dataStorage:
    enabled: false # we will use dynamodb backend for storage, not a local PVC
  auditStorage:
    enabled: false # we will use dynamodb backend for storage, not a local PVC
  standalone:
    enabled: true
    config: |
      ${vault_config}
  ha:
    enabled: false
ui:
  enabled: true

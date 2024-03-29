global:
  tlsDisable: false

server:
  image:
    tag: ${vault_version}
  service:
    enabled: true
    type: LoadBalancer
    port: 443
    annotations: |
      "service.beta.kubernetes.io/aws-load-balancer-internal": "true"
      "external-dns.alpha.kubernetes.io/hostname": "${vault_hostname}"
  dataStorage:
    enabled: false # we will use dynamodb backend for storage, not a local PVC
  auditStorage:
    enabled: false # we will use dynamodb backend for storage, not a local PVC
  standalone:
    enabled: false
  extraVolumes:
    - type: secret
      name: ${vault_tls_secret}
      path: "/tls"
  ha:
    enabled: true
    config: |
      ${vault_config}
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 500m
      memory: 128Mi

ui:
  enabled: true

server:
  dataStorage:
    enabled: false # we will use s3 backend for storage, not a local PVC
  auditStorage:
    enabled: false # we will use s3 backend for storage, not a local PVC
  standalone:
    enabled: false
  extraVolumes:
    - type: secret
      name: ${vault_tls_secret}
      path: "/tls-certificate"
  ha:
    enabled: true
    config: |
      ${vault_config}
ui:
  enabled: true

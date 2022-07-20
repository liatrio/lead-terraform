global:
  tlsDisable: true

server:
  service:
    enabled: true
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: ${ingress_class}
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
  resources:
    requests:
      memory: 128Mi
      cpu: 64m
    limits:
      memory: 256Mi
      cpu: 512m
  serviceAccount:
    create: false
    name: vault

  extraContainers:
    - name: vault-init
      image: ghcr.io/liatrio/vault-init:v0.3
      env:
        - name: K8S_SECRET_NAME
          value: ${vault_credentials_secret_name}
        - name: KMS_KEY_ID
          value: ${kms_key_id}
        - name: KMS_REGION
          value: ${kms_region}
        - name: VAULT_ADDR
          value: http://127.0.0.1:8200

ui:
  enabled: true

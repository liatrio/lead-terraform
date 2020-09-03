clusterDomain: ${cluster_domain}

serviceAccount:
  name: keycloak

extraVolumeMounts: |
  - name: creds
    mountPath: /secrets/creds
    readOnly: true

extraVolumes: |
  - name: creds
    secret:
      secretName: ${keycloak_secret}

extraEnv: |
  - name: PROXY_ADDRESS_FORWARDING
    value: "true"
  - name: KEYCLOAK_USER_FILE
    value: /secrets/creds/admin_username
  - name: KEYCLOAK_PASSWORD_FILE
    value: /secrets/creds/admin_password
  - name: KEYCLOAK_LOGLEVEL
    value: "DEBUG"


ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "toolchain-nginx"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "${ssl_redirect}"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Forwarded-Proto: https";
    ingress.kubernetes.io/proxy-body-size: "0"
    ingress.kubernetes.io/proxy-read-timeout: "600"
    ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  hosts:
  - ${ingress_hostname}
  tls:
  - hosts:
    - ${ingress_hostname}
  path: /

resources:
  requests:
    memory: 600Mi
    cpu: 50m
  limits:
    memory: 800Mi
    cpu: 1

postgresql:
  resources:
    requests:
      memory: 64Mi
      cpu: 10m
    limits:
      memory: 128Mi
      cpu: 500m

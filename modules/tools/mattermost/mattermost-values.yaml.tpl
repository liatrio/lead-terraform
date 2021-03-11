mysql:
  enabled: false

externalDB:
  enabled: true
  externalDriverType: postgres

ingress:
  enabled: true
  hosts:
    - ${mattermost_hostname}
  tls:
    - hosts:
      - ${mattermost_hostname}
  annotations:
    kubernetes.io/ingress.class: "toolchain-nginx"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"

persistence:
  data:
    enabled: true
  plugins:
    enabled: true
  config:
    enabled: true

configJSON:
  ServiceSettings:
    SiteURL: "https://${mattermost_hostname}"

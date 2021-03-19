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
    # set max body size for plugin uploading
    nginx.ingress.kubernetes.io/proxy-body-size: 32m

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

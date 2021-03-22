artifactory:
  artifactory:
    admin:
      ip: "*"
      username: "admin"

  ingress:
    enabled: ${ingress_enabled}
    hosts:
    - ${artifactory_jcr_hostname}
    tls:
    - hosts:
      - ${artifactory_jcr_hostname}
    annotations:
      kubernetes.io/ingress.class: "toolchain-nginx"
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"

  postgresql:
    enabled: true
    postgresqlUsername: "artifactory"
    resources:
      limits:
        memory: 256Mi
        cpu: 250m
      requests:
        memory: 64Mi
        cpu: 64m
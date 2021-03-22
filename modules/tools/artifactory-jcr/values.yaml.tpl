artifactory:
  artifactory:
    admin:
      ip: "*"
      username: "admin"
      password: ${jcr_admin_password}

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

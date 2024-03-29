artifactory:
  artifactory:
    admin:
      ip: "*"
      username: "admin"

    configMapName: artifactory-eula-config

    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "4Gi"
        cpu: "1"
        
  nginx:
    enabled: false

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
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      
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
        
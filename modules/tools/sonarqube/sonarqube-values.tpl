sonarProperties:
  sonar.forceAuthentication: ${ force_authentication }
plugins:
  install:
  - "https://github.com/vaulttec/sonar-auth-oidc/releases/download/v2.0.0/sonar-auth-oidc-plugin-2.0.0.jar"
ingress:
  enabled: ${ ingress_enabled }
  hosts:
    - name: ${ ingress_hostname }
      path: "/"
  annotations:
    ${indent( 4, yamlencode( ingress_annotations ) ) }
resources:
  requests:
    cpu: 50m
    memory: 1.5Gi
  limits:
    cpu: 600m
    memory: 2.5Gi
postgresql:
  resources:
    requests:
      cpu: 50m
      memory: 32Mi
    limits:
      cpu: 150m
      memory: 64Mi

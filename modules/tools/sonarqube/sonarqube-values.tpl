image:
  repository: sonarqube
  tag: 8.9.4-community

# https://community.sonarsource.com/t/sonarqube-sonarcloud-and-the-log4j-vulnerability/54721/39
env:
  - name: SONAR_SEARCH_JAVAADDITIONALOPTS
    value: "-Dlog4j2.formatMsgNoLookups=true"

sonarProperties:
  sonar.forceAuthentication: ${ force_authentication }
  %{~ if enable_keycloak ~}
  sonar.auth.oidc.enabled: true
  sonar.auth.oidc.issuerUri: ${keycloak_issuer_uri}
  sonar.auth.oidc.clientId.secured: ${keycloak_client_id}
  sonar.auth.oidc.loginButtonText: Keycloak
  %{~ endif ~}

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

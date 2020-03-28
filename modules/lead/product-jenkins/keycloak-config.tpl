unclassified:
  keycloakSecurityRealm:
    keycloakJson: >
      {
        "realm": "toolchain",
        "auth-server-url": "${keycloak_url}",
        "ssl-required": "${keycloak_ssl}",
        "resource": "${ingress_hostname}",
        "public-client": true
      }
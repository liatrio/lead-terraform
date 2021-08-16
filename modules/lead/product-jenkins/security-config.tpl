jenkins:
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: ${!enable_keycloak}
  %{~ if enable_keycloak }
  securityRealm: keycloak
  %{~ endif }

jenkins:
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      %{~ if enable_keycloak }
      allowAnonymousRead: "false"
    securityRealm: keycloak
      %{~ else }
      allowAnonymousRead: "true"
      %{~ endif }

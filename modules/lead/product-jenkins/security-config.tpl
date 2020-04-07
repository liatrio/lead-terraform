jenkins:
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: "${allow_anonymous_read}"
  securityRealm: ${security_realm}

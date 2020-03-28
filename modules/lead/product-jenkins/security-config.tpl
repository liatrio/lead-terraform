jenkins:
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: "${allow_anonymous_read}"
  ${security_realm}
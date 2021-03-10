postgresqlUsername: ${postgres_username}
postgresqlDatabase: ${postgres_database}
resources:
  limits:
    memory: 256Mi
    cpu: 250m
  requests:
    memory: 64Mi
    cpu: 64m

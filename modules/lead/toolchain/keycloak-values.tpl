clusterDomain: ${cluster_domain}

keycloak:
  serviceAccount:
    # Specifies whether a service account should be created
    create: true
    # The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template
    name: keycloak

  # Specifies an existing secret to be used for the admin password
  existingSecret: "keycloak-admin-credential"

  # The key in the existing secret that stores the password
  existingSecretKey: password

  ## Allows the specification of additional environment variables for Keycloak
  extraEnv: |
    - name: PROXY_ADDRESS_FORWARDING
      value: "true"
    # - name: KEYCLOAK_LOGLEVEL
    #   value: DEBUG
    # - name: WILDFLY_LOGLEVEL
    #   value: DEBUG
    # - name: CACHE_OWNERS
    #   value: "2"
    # - name: DB_QUERY_TIMEOUT
    #   value: "60"
    # - name: DB_VALIDATE_ON_MATCH
    #   value: true
    # - name: DB_USE_CAST_FAIL
    #   value: false

  ## Custom startup scripts to run before Keycloak starts up
  startupScripts: 
    startup.sh: |
      #!/bin/sh
      export PATH=$PATH:/opt/jboss/keycloak/bin/
      echo "importing realm from export /realm/toolchain_realm.json..."
      standalone.sh -Dkeycloak.migration.action=import -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=/realm/toolchain_realm.json -Dkeycloak.migration.strategy=IGNORE_EXISTING

  extraVolumes: |
    - name: realm-secret
      secret:
        secretName: ${realm_secret}

  extraVolumeMounts: |
    - name: realm-secret
      mountPath: "/realm/"
      readOnly: true

  ## This only works with manually created non-exported realms...
  ## "When importing realm files that weren’t exported before, the option keycloak.import can be used"
  ## https://www.keycloak.org/docs/latest/server_admin/index.html#_export_import
  #extraArgs: -Dkeycloak.import=/realm/toolchain_realm.json

  ## Ingress configuration.
  ## ref: https://kubernetes.io/docs/user-guide/ingress/
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
      ingress.kubernetes.io/proxy-body-size: "0"
      ingress.kubernetes.io/proxy-read-timeout: "600"
      ingress.kubernetes.io/proxy-send-timeout: "600"
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
    hosts:
    - ${ingress_hostname}
    tls:
    - hosts:
      - ${ingress_hostname}
      secretName: keycloak-ingress-tls    
    path: /

  ## Persistence configuration
  persistence:
    # If true, the Postgres chart is deployed
    deployPostgres: true

    # The database vendor. Can be either "postgres", "mysql", "mariadb", or "h2"
    dbVendor: postgres

postgresql:
  ### PostgreSQL User to create.
  ##
  postgresqlUsername: keycloak

  ## PostgreSQL Database to create.
  ##
  postgresqlDatabase: keycloak

  ## Persistent Volume Storage configuration.
  ## ref: https://kubernetes.io/docs/user-guide/persistent-volumes
  ##
  persistence:
    ## Enable PostgreSQL persistence using Persistent Volume Claims.
    ##
    enabled: true


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

  ## Ingress configuration.
  ## ref: https://kubernetes.io/docs/user-guide/ingress/
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      acme.cert-manager.io/http01-edit-in-place: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "${ssl_redirect}"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
      nginx.ingress.kubernetes.io/configuration-snippet: |
        more_set_headers "X-Forwarded-Proto: https";      
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

  resources:
    requests:
      memory: 600Mi
      cpu: 50m
    limits:
      memory: 800Mi
      cpu: 1 


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
  
  resources:
    requests:
      memory: 64Mi
      cpu: 10m
    limits:
      memory: 128Mi
      cpu: 100m

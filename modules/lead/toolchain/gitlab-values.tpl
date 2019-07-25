global:
  edition: ce
  hosts:
    domain: ${ingress_hostname}
    https: ${ssl_redirect}
    gitlab:
      name: ui.${ingress_hostname}
  ingress:
    enabled: true
    configureCertmanager: false
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
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
      secretName: gitlab-ingress-tls
  ## doc/charts/globals.md#configure-appconfig-settings
  ## Rails based portions of this chart share many settings
  appConfig:
    ## doc/charts/globals.md#general-application-settings
    enableUsagePing: true
    enableImpersonation:
    defaultCanCreateGroup: true
    usernameChangingEnabled: false
    issueClosingPattern:
    defaultTheme:
    defaultProjectsFeatures:
      issues: true
      mergeRequests: true
      wiki: true
      snippets: true
      builds: false
      container_registry: false
    webhookTimeout:
    omniauth:
      enabled: true
      autoSignInWithProvider: 'saml'
      syncProfileFromProvider: ['saml']
      syncProfileAttributes: ['email']
      allowSingleSignOn: ['saml']
      blockAutoCreatedUsers: false
      autoLinkSamlUser: true
      providers:
        - secret: gitlab-keycloak-saml


  smtp:
    enabled: true
    address: ${smtp_host}
    port: ${smtp_port}
    authentication: 
  email:
    from: ${smtp_from_email}
    display_name: ${smtp_from_name}
    reply_to: ${smtp_replyto}
    subject_suffix: " | ${smtp_from_name}"
  operator:
    enabled: false

certmanager:
  install: false
nginx-ingress:
  enabled: false
prometheus:
  install: false
gitlab-runner:
  install: false
registry:
  enabled: false
gitlab:
  gitaly:
    persistence:
      size: 10G
  unicorn:
    minReplicas: 1
    maxReplicas: 1
    resources:
      requests:
        cpu: 200m
        memory: 1.4Gi
      limits:
        cpu: 800m
        memory: 2Gi
  sidekiq:
    minReplicas: 1
    maxReplicas: 1
    resources:
      requests:
        cpu: 100m
        memory: 600Mi
      limits:
        cpu: 500
        memory: 1.5Gi
  gitlab-shell:
    enabled: false
  task-runner:
    enabled: false

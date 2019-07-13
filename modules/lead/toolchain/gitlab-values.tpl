global:
  hosts:
    domain: ${ingress_hostname}
  ingress:
    enabled: true
    configureCertmanager: true
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
      secretName: gitlab-ingress-tls
  initialRootPassword:
    secret: ${gitlab_admin_password_secret}
    key: ${gitlab_admin_password_key}
  psql:
    password:
      secret: ${gitlab_db_password_secret}
      key: ${gitlab_db_password_key}
  ## doc/charts/globals.md#configure-appconfig-settings
  ## Rails based portions of this chart share many settings
  appConfig:
    ## doc/charts/globals.md#general-application-settings
    enableUsagePing: true
    enableImpersonation:
    defaultCanCreateGroup: true
    usernameChangingEnabled: true
    issueClosingPattern:
    defaultTheme:
    defaultProjectsFeatures:
      issues: true
      mergeRequests: true
      wiki: true
      snippets: true
      builds: true
    webhookTimeout: 

  smtp:
    enabled: true
    address: ${smtp_host}
    port: ${smtp_port}
    user_name: ${smtp_username}
    password:
      secret: ${smtp_secret_name}
      key: ${smtp_secret_key}
  email:
    from: ${smtp_from_email}
    display_name: ${smtp_from_name}
    reply_to: ${smtp_replyto}
    subject_suffix: " | ${smtp_from_name}"
  operator:
    enabled: true


certmanager:
  install: false
nginx-ingress:
  enabled: false

prometheus:
  install: false
gitlab-runner:
  install: false
redis:
  minReplicas: 1
  maxReplicas: 1
  resources:
    requests:
      cpu: 10m
      memory: 64Mi
minio:
  minReplicas: 1
  maxReplicas: 1
  resources:
    requests:
      memory: 64Mi
      cpu: 10m
# Reduce replica counts, reducing CPU & memory requirements
gitlab:
  unicorn:
    minReplicas: 1
    maxReplicas: 1
    resources:
      limits:
       memory: 1.5G
      requests:
        cpu: 100m
        memory: 900M
    workhorse:
      resources:
        limits:
          memory: 100M
        requests:
          cpu: 10m
          memory: 10M
  sidekiq:
    minReplicas: 1
    maxReplicas: 1
    resources:
      limits:
        memory: 1.5G
      requests:
        cpu: 50m
        memory: 625M
  gitlab-shell:
    enabled: false
  task-runner:
    enabled: false

serviceAccount:
  create: false
  name: ${service_account_name}

persistence:
  enabled: true

controller:
  image: harbor.parker.gg/library/jenkins-updated-plugins
  tag: v6

  installPlugins: false

  serviceType: ClusterIP
  jenkinsUrlProtocol: ${protocol}
  ingress:
    enabled: true
    hostName: ${ingress_hostname}
    annotations:
      kubernetes.io/ingress.class: "jenkins-nginx"
      nginx.ingress.kubernetes.io/force-ssl-redirect: "${ssl_redirect}"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
      nginx.ingress.kubernetes.io/configuration-snippet: |
        more_set_headers "X-Forwarded-Proto: https";
      ingress.kubernetes.io/proxy-body-size: "0"
      ingress.kubernetes.io/proxy-read-timeout: "600"
      ingress.kubernetes.io/proxy-send-timeout: "600"
    tls:
    - hosts:
      - ${ingress_hostname}

  probes:
    livenessProbe:
      failureThreshold: 5
      initialDelaySeconds: 60
    readinessProbe:
      failureThreshold: 12
      initialDelaySeconds: 30

  resources:
    requests:
      cpu: 250m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi

  JCasC:
    defaultConfig: false
    enabled: true
    configScripts:
      welcome-message: |
        jenkins:
          systemMessage: Welcome to our CI\CD server.  This Jenkins is configured and managed 'as code' from https://github.com/liatrio/lead-terraform.

  sidecars:
    configAutoReload:
      enabled: true
      resources:
        requests:
          cpu: 100m
          memory: 64Mi
        limits:
          cpu: 800m
          memory: 256Mi

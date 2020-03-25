serviceAccount:
  create: false
  name: jenkins

persistence:
  enabled: false

master:
  installPlugins: false
  image: "${toolchain_image_repo}/jenkins-image"
  tag: ${jenkins_image_version}
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
  jenkinsUrlProtocol: ${protocol}
  serviceType: ClusterIP
  healthProbeLivenessFailureThreshold: 5
  healthProbeReadinessFailureThreshold: 12
  healthProbeLivenessInitialDelay: 60
  healthProbeReadinessInitialDelay: 30
  resources:
    requests:
      cpu: 250m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi


  JCasC:
    enabled: true
    pluginVersion: 1.19
    supportPluginVersion: 1.19
    configScripts:
      welcome-message: |
        jenkins:
          systemMessage: Welcome to our CI\CD server.  This Jenkins is configured and managed 'as code' from https://github.com/liatrio/lead-terraform.
      security-config: |
        jenkins:
          authorizationStrategy:
            loggedInUsersCanDoAnything:
              allowAnonymousRead: "${allow_anonymous_read}"
          ${security_realm}
      keycloak-config: |
        unclassified:
          keycloakSecurityRealm:
            keycloakJson: >
              {
                "realm": "toolchain",
                "auth-server-url": "${keycloak_url}",
                "ssl-required": "${keycloak_ssl}",
                "resource": "${ingress_hostname}",
                "public-client": true
              }
      master-node: |
        jenkins:
          labelString: "master"
          numExecutors: 1
      logstash-url: |
        jenkins:
          globalNodeProperties:
            - envVars:
                env:
                - key: "elasticUrl"
                  value: "${logstash_url}"
                - key: "toolchainNamespace"
                  value: "${toolchain_namespace}"
                - key: "product"
                  value: "${product_name}"
                - key: "stagingNamespace"
                  value: "${stagingNamespace}"
                - key: "productionNamespace"
                  value: "${productionNamespace}"
                - key: "stagingDomain"
                  value: "staging.${appDomain}"
                - key: "productionDomain"
                  value: "prod.${appDomain}"


  containerEnv:
    - name: elasticUrl
      value: http://lead-dashboard-logstash.toolchain.svc.cluster.local:9000

  sidecars:
    configAutoReload:
      enabled: true
      label: jenkins_config
      resources:
        requests:
          cpu: 100m
          memory: 64Mi
        limits:
          cpu: 800m
          memory: 256Mi

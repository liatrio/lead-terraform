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
      slack-config: |
        unclassified:
          slackNotifier:
            teamDomain: "${slack_team}"
            tokenCredentialId: jenkins-credential-slack
      pod-templates: |
        jenkins:
          clouds:
            - kubernetes:
                name: "kubernetes"
                serverUrl: "https://kubernetes.default"
                namespace: "${namespace}"
                jenkinsUrl: "http://jenkins:8080"
                jenkinsTunnel: "jenkins-agent:50000"
                connectTimeout: 0
                readTimeout: 0
                containerCapStr: 15
                podRetention: never
                maxRequestsPerHostStr: 32
                waitForPodSec: 600
                templates:
                  - name: "lead-toolchain-skaffold"
                    label: "lead-toolchain-skaffold"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "skaffold"
                        image: "${toolchain_image_repo}/builder-image-skaffold:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins/agent"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                        resourceRequestCpu: 250m
                        resourceLimitCpu: 500m
                        resourceRequestMemory: 256Mi
                        resourceLimitMemory: 512Mi
                    envVars:
                      - envVar:
                          key: "SKAFFOLD_DEFAULT_REPO"
                          value: "${product_image_repo}/${product_name}"
                    volumes:
                      - hostPathVolume:
                          hostPath: "/var/run/docker.sock"
                          mountPath: "/var/run/docker.sock"
                      - secretVolume:
                          mountPath: "/root/.docker"
                          secretName: "${jenkins-repository-dockercfg}"
                    slaveConnectTimeout: 100
                    serviceAccount: "jenkins"
                    yaml: |-
                      apiVersion: v1
                      kind: Pod
                      spec:
                        containers:
                        - name: jnlp
                          resources:
                            requests:
                              cpu: 200m
                              memory: 128Mi
                            limits:
                              cpu: 1
                              memory: 256Mi
                    yamlMergeStrategy: "merge"
                  - name: "lead-toolchain-aws"
                    label: "lead-toolchain-aws"
                    nodeUsageMode: NORMAL
                    yaml: |-
                      spec:
                        securityContext:
                          fsGroup: 1000
                    containers:
                      - name: "aws"
                        image: "${toolchain_image_repo}/builder-image-aws:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins/agent"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                        resourceRequestCpu: 100m
                        resourceLimitCpu: 250m
                        resourceRequestMemory: 128Mi
                        resourceLimitMemory: 256Mi
                    slaveConnectTimeout: 100
                    yaml: |-
                      apiVersion: v1
                      kind: Pod
                      spec:
                        containers:
                        - name: jnlp
                          resources:
                            requests:
                              cpu: 200m
                              memory: 128Mi
                            limits:
                              cpu: 1
                              memory: 256Mi
                    yamlMergeStrategy: "merge"
                  - name: "lead-toolchain-terraform"
                    label: "lead-toolchain-terraform"
                    nodeUsageMode: NORMAL
                    yaml: |-
                      spec:
                        securityContext:
                          fsGroup: 1000
                    containers:
                      - name: "terraform"
                        image: "${toolchain_image_repo}/builder-image-terraform:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins/agent"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                        resourceRequestCpu: 100m
                        resourceLimitCpu: 1
                        resourceRequestMemory: 256Mi
                        resourceLimitMemory: 1536Mi
                    slaveConnectTimeout: 100
                    yaml: |-
                      apiVersion: v1
                      kind: Pod
                      spec:
                        containers:
                        - name: jnlp
                          resources:
                            requests:
                              cpu: 200m
                              memory: 128Mi
                            limits:
                              cpu: 1
                              memory: 256Mi
                    yamlMergeStrategy: "merge"
                  - name: "lead-toolchain-maven"
                    label: "lead-toolchain-maven"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "maven"
                        image: "${toolchain_image_repo}/builder-image-maven:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins/agent"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                        resourceRequestCpu: 100m
                        resourceLimitCpu: 250m
                        resourceRequestMemory: 256Mi
                        resourceLimitMemory: 1024Mi
                    slaveConnectTimeout: 100
                    volumes:
                      - secretVolume:
                          mountPath: "/root/.m2"
                          secretName: "jenkins-artifactory-maven-settings"
                      - emptyDirVolume:
                          mountPath: "/root/.m2/repository"
                          memory: false
                    yaml: |-
                      apiVersion: v1
                      kind: Pod
                      spec:
                        containers:
                        - name: jnlp
                          resources:
                            requests:
                              cpu: 200m
                              memory: 128Mi
                            limits:
                              cpu: 1
                              memory: 256Mi
                    yamlMergeStrategy: "merge"
                  - name: "lead-toolchain-gitops"
                    label: "lead-toolchain-gitops"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "gitops"
                        image: "${toolchain_image_repo}/builder-image-gitops:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins/agent"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                        resourceRequestCpu: 100m
                        resourceLimitCpu: 250m
                        resourceRequestMemory: 128Mi
                        resourceLimitMemory: 256Mi
                    slaveConnectTimeout: 100
                    envVars:
                    - secretEnvVar:
                        key: "GITOPS_GIT_USERNAME"
                        secretKey: "username"
                        secretName: "jenkins-credential-github"
                    - secretEnvVar:
                        key: "GITOPS_GIT_PASSWORD"
                        secretKey: "password"
                        secretName: "jenkins-credential-github"
                    yaml: |-
                      apiVersion: v1
                      kind: Pod
                      spec:
                        containers:
                        - name: jnlp
                          resources:
                            requests:
                              cpu: 200m
                              memory: 128Mi
                            limits:
                              cpu: 1
                              memory: 256Mi
                    yamlMergeStrategy: "merge"
                  - name: "lead-toolchain-goreleaser"
                    label: "lead-toolchain-goreleaser"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "goreleaser"
                        image: "${toolchain_image_repo}/builder-image-goreleaser:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins/agent"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                        resourceRequestCpu: 100m
                        resourceLimitCpu: 250m
                        resourceRequestMemory: 128Mi
                        resourceLimitMemory: 256Mi
                    yaml: |-
                      apiVersion: v1
                      kind: Pod
                      spec:
                        containers:
                        - name: jnlp
                          resources:
                            requests:
                              cpu: 200m
                              memory: 128Mi
                            limits:
                              cpu: 1
                              memory: 256Mi
                    yamlMergeStrategy: "merge"
      shared-libraries: |
        unclassified:
          globalLibraries:
            libraries:
            - defaultVersion: "master"
              name: "pipeline-library"
              retriever:
                modernSCM:
                  scm:
                    git:
                      remote: "https://github.com/liatrio/pipeline-library"
            - defaultVersion: "master"
              name: "LEAD"
              retriever:
                modernSCM:
                  scm:
                    git:
                      remote: "https://github.com/liatrio/lead-shared-library.git"

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

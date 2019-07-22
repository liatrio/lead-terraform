serviceAccount:
  create: false
  name: jenkins

master:
  ingress:
    enabled: true
    hostName: ${ingress_hostname}
    annotations:
      kubernetes.io/ingress.class: "nginx"
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    tls:
    - hosts:
      - ${ingress_hostname}
      secretName: jenkins-ingress-tls
  jenkinsUrlProtocol: https
  serviceType: ClusterIP
  healthProbeLivenessFailureThreshold: 5
  healthProbeReadinessFailureThreshold: 12
  healthProbeLivenessInitialDelay: 240
  healthProbeReadinessInitialDelay: 120

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
          authorizationStrategy: loggedInUsersCanDoAnything
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
                  value: "${stagingDomain}"
                - key: "productionDomain"
                  value: "${productionDomain}"
      slack-config: |
        unclassified:
          slackNotifier:
            teamDomain: "${slack_team}"
            tokenCredentialId: jenkins-credential-slack
      gitlab-config: |
        unclassified:
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
                containerCapStr: 5
                podRetention: never
                maxRequestsPerHostStr: 32
                waitForPodSec: 600
                templates:
                  - name: "lead-toolchain-skaffold"
                    label: "lead-toolchain-skaffold"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "skaffold"
                        image: "docker.artifactory.liatr.io/liatrio/builder-image-skaffold:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                    envVars:
                      - envVar:
                          key: "SKAFFOLD_DEFAULT_REPO"
                          value: "${artifactory_url}/${product_name}"
                    volumes:
                      - hostPathVolume:
                          hostPath: "/var/run/docker.sock"
                          mountPath: "/var/run/docker.sock"
                      - secretVolume:
                          mountPath: "/home/jenkins/.docker"
                          secretName: "jenkins-artifactory-dockercfg"
                    slaveConnectTimeout: 100
                    serviceAccount: "jenkins"
                  - name: "lead-toolchain-aws"
                    label: "lead-toolchain-aws"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "aws"
                        image: "docker.artifactory.liatr.io/liatrio/builder-image-aws:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                    slaveConnectTimeout: 100
                  - name: "lead-toolchain-terraform"
                    label: "lead-toolchain-terraform"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "terraform"
                        image: "docker.artifactory.liatr.io/liatrio/builder-image-terraform:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                    slaveConnectTimeout: 100
                  - name: "lead-toolchain-maven"
                    label: "lead-toolchain-maven"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "maven"
                        image: "docker.artifactory.liatr.io/liatrio/builder-image-maven:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                    slaveConnectTimeout: 100
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
  installPlugins:
    - ws-cleanup:0.37
    - kubernetes-credentials-provider:0.12.1
    - slack:2.24
    - pipeline-utility-steps:2.3.0
    - http_request:1.8.22
    - github-branch-source:2.5.3
    - workflow-aggregator:2.6
    - pipeline-model-definition:1.3.8
    - workflow-api:2.34
    - workflow-scm-step:2.8
    - kubernetes:1.15.6
    - job-dsl:1.74
    - blueocean:1.4.1
    - git:3.10.1
    - gitlab:1.5.12

  containerEnv:
    - name: elasticUrl
      value: http://lead-dashboard-logstash.toolchain.svc.cluster.local:9000

  sidecars:
    configAutoReload:
      enabled: true
      label: jenkins_config

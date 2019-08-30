serviceAccount:
  create: false
  name: jenkins

persistence:
  enabled: false

master:
  installPlugins: false
  image: "docker.artifactory.liatr.io/liatrio/jenkins-image"
  tag: ${jenkins_image_version}
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
  healthProbeLivenessInitialDelay: 60 
  healthProbeReadinessInitialDelay: 30
  resources:
    requests:
      cpu: 100m
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
          authorizationStrategy: loggedInUsersCanDoAnything
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
                  value: "${stagingDomain}"
                - key: "productionDomain"
                  value: "${productionDomain}"
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
                        workingDir: "/home/jenkins/agent"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                        resourceRequestCpu: 128m
                        resourceLimitCpu: 256m
                        resourceRequestMemory: 128Mi
                        resourceLimitMemory: 256Mi
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
                        workingDir: "/home/jenkins/agent"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                        resourceRequestCpu: 128m
                        resourceLimitCpu: 256m
                        resourceRequestMemory: 128Mi
                        resourceLimitMemory: 256Mi
                    slaveConnectTimeout: 100
                  - name: "lead-toolchain-terraform"
                    label: "lead-toolchain-terraform"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "terraform"
                        image: "docker.artifactory.liatr.io/liatrio/builder-image-terraform:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins/agent"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                        resourceRequestCpu: 128m
                        resourceLimitCpu: 256m
                        resourceRequestMemory: 128Mi
                        resourceLimitMemory: 256Mi
                    slaveConnectTimeout: 100
                  - name: "lead-toolchain-maven"
                    label: "lead-toolchain-maven"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "maven"
                        image: "docker.artifactory.liatr.io/liatrio/builder-image-maven:${builder_images_version}"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins/agent"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                        resourceRequestCpu: 128m
                        resourceLimitCpu: 256m
                        resourceRequestMemory: 128Mi
                        resourceLimitMemory: 256Mi
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

  containerEnv:
    - name: elasticUrl
      value: http://lead-dashboard-logstash.toolchain.svc.cluster.local:9000

  sidecars:
    configAutoReload:
      enabled: true
      label: jenkins_config

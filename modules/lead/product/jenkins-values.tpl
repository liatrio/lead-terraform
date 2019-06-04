serviceAccount:
  create: false
  name: jenkins

master:
  ingress:
    enabled: true
    hostName: ${ingress_hostname}
  jenkinsUrlProtocol: https
  serviceType: ClusterIP

  JCasC:
    enabled: true
    pluginVersion: 1.13
    supportPluginVersion: 1.13
    configScripts:
      welcome-message: |
        jenkins:
          systemMessage: Welcome to our CI\CD server.  This Jenkins is configured and managed 'as code' from https://github.com/liatrio/lead-toolchain.
      logstash-url: |
        jenkins:
          globalNodeProperties:
            - envVars:
                env:
                - key: "elasticUrl"
                  value: "${logstash_url}"
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
                namespace: "toolchain"
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
                        image: "docker.artifactory.liatr.io/liatrio/builder-image-skaffold:v1.0.4"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true
                    envVars:
                      - envVar:
                          key: "SKAFFOLD_DEFAULT_REPO"
                          value: "docker.artifactory.liatr.io/liatrio"
                    volumes:
                      - hostPathVolume:
                          hostPath: "/var/run/docker.sock"
                          mountPath: "/var/run/docker.sock"
                    slaveConnectTimeout: 100
                  - name: "lead-toolchain-skaffold-node"
                    inheritFrom: "lead-toolchain-skaffold"
                    label: "lead-toolchain-skaffold-node"
                    nodeUsageMode: NORMAL
                    containers:
                      - name: "node"
                        image: "node:10"
                        alwaysPullImage: false
                        workingDir: "/home/jenkins"
                        command: "/bin/sh -c"
                        args: "cat"
                        ttyEnabled: true 
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
  installPlugins:
    - ws-cleanup:latest
    - kubernetes-credentials-provider:latest
    - slack:latest
    - pipeline-utility-steps:latest
    - http_request:latest
    - github-branch-source:latest
    - workflow-aggregator:latest

  containerEnv:
    - name: elasticUrl
      value: http://lead-dashboard-logstash.${namespace}.svc.cluster.local:9000

  sidecars:
    configAutoReload:
      enabled: true
      label: jenkins_config

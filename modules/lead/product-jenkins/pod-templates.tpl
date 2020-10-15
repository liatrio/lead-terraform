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
                ${essential_tolerations}
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
                ${essential_tolerations}
                securityContext:
                  fsGroup: 1000
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
                ${essential_tolerations}
                securityContext:
                  fsGroup: 1000
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
          - name: "lead-toolchain-terratest"
            label: "lead-toolchain-terratest"
            nodeUsageMode: NORMAL
            containers:
              - name: "terratest"
                image: "${toolchain_image_repo}/builder-image-terratest:${builder_images_version}"
                alwaysPullImage: false
                workingDir: "/home/jenkins/agent"
                command: "/bin/sh -c"
                args: "cat"
                ttyEnabled: true
                resourceRequestCpu: 300m
                resourceLimitCpu: 1
                resourceRequestMemory: 256Mi
                resourceLimitMemory: 1Gi
            slaveConnectTimeout: 100
            yaml: |-
              apiVersion: v1
              kind: Pod
              spec:
                ${essential_tolerations}
                securityContext:
                  fsGroup: 1000
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
              - emptyDirVolume:
                  mountPath: "/root/.m2/repository"
                  memory: false
            yaml: |-
              apiVersion: v1
              kind: Pod
              spec:
                ${essential_tolerations}
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
          - name: "lead-toolchain-gradle"
            label: "lead-toolchain-gradle"
            nodeUsageMode: NORMAL
            containers:
              - name: "gradle"
                image: "${toolchain_image_repo}/builder-image-gradle:${builder_images_version}"
                alwaysPullImage: false
                workingDir: "/home/jenkins/agent"
                command: "/bin/sh -c"
                args: "cat"
                ttyEnabled: true
                resourceRequestCpu: 100m
                resourceLimitCpu: 500m
                resourceRequestMemory: 256Mi
                resourceLimitMemory: 1024Mi
            slaveConnectTimeout: 100
            volumes:
              - emptyDirVolume:
                  mountPath: "/root/.m2/repository"
                  memory: false
            yaml: |-
              apiVersion: v1
              kind: Pod
              spec:
                ${essential_tolerations}
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
                ${essential_tolerations}
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
                ${essential_tolerations}
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

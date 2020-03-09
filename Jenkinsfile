pipeline {
  agent {
    kubernetes {
      label 'lead-toolchain-aws-for-lead-environments'
      inheritFrom 'lead-toolchain-aws lead-toolchain-terratest lead-toolchain-gitops'
      yaml """
      spec:
        serviceAccount: "aws-builder"
        containers:
        - name: jnlp
          resources:
            requests:
              cpu: 200m
              memory: 128Mi
            limits:
              cpu: 1
              memory: 256Mi
      """
    }
  }
  environment {
    VERSION = version()
  }
  stages {
    stage('Validate Terraform') {
      environment {
        TF_VALIDATE_ARGS = "-no-color"
      }
      steps {
        container('terratest') {
          sh "make validate"
        }
        stageMessage "Validated terraform for product version: ${VERSION}"
      }
    }
    stage('Test Terraform') {
      when {
        anyOf {
          branch 'master'
          branch 'PR-*'
        }
      }
      steps {
        container('aws') {
          script {
            env.AWS_ROLE_SESSION_NAME="lead-environments"
            def roleArn = "arn:aws:iam::003744521125:role/LeadEnvironmentsBastion"
            def assumeRoleCreds = readJSON(text: sh(returnStdout: true, script: "aws sts assume-role --role-arn ${roleArn} --role-session-name ${AWS_ROLE_SESSION_NAME} --duration-seconds 3600")).Credentials
            env.AWS_ACCESS_KEY_ID=assumeRoleCreds.AccessKeyId
            env.AWS_SECRET_ACCESS_KEY=assumeRoleCreds.SecretAccessKey
            env.AWS_SESSION_TOKEN=assumeRoleCreds.SessionToken
            env.TERRATEST_IAM_ROLE="arn:aws:iam::774051255656:role/Administrator"
          }
        }
        container('terratest') {
          dir ("tests") {
            sh "go test liatr.io/lead-terraform/tests/aws -timeout 60m -v --count=1"
          }
        }
      }
    }
    stage('Gitops') {
      when {
        branch 'master'
      }
      environment {
        GITOPS_GIT_URL = "https://github.com/liatrio/lead-environments.git"
        GITOPS_REPO_FILE = "aws/liatrio-sandbox/terragrunt.hcl"
        GITOPS_VALUES = "inputs.product_version=${VERSION}"
      }
      steps {
        container('gitops') {
          sh "/go/bin/gitops"
        }
        stageMessage "Updated the product version in sandbox to: ${VERSION}"
      }
    }
  }
}
def version() {
  return sh(script: 'git rev-parse --verify --short HEAD', returnStdout: true).trim();
}

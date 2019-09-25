library 'LEAD'
pipeline {
  agent any
  environment {
    VERSION = version()
  }
  stages {
    stage('Validate Terraform') {
      agent {
        label "lead-toolchain-terraform"
      }
      steps {
        notifyPipelineStart()
        notifyStageStart()                                                                                                                                                                      
        container('terraform') {
          sh "make validate"
        }
        notifyStageEnd([status: "Validated terraform for product version: ${VERSION}"])
      }
      post {
        failure {
          notifyStageEnd([result: "fail"])
        }
      }
    }
    stage('Gitops') {
      agent {
        label "lead-toolchain-gitops"
      }
      when {
        branch = master
      }
      environment {
        GITOPS_GIT_URL = "https://github.com/liatrio/lead-environments.git"
        GITOPS_REPO_FILE = "aws/liatrio-sandbox/terragrunt.hcl"
        GITOPS_VALUES = "inputs.product_version=${VERSION}"
      }
      steps {
        notifyStageStart()
        container('gitops') {
          sh "/go/bin/gitops"
        }
        notifyStageEnd([status: "Updated the product version in sandbox to: ${VERSION}"])
      }
      post {
        failure {
          notifyStageEnd([result: "fail"])
        }
      }
    }
  }
}
def version() {
  return sh(script: 'git describe --tags', returnStdout: true).trim();
}

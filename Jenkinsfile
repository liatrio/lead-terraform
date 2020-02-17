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
        container('terraform') {
          sh "make validate"
        }
        stageMessage "Validated terraform for product version: ${VERSION}"
      }
    }
    stage('Gitops') {
      agent {
        label "lead-toolchain-gitops"
      }
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

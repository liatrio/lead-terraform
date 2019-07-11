pipeline {
    agent {
        label "lead-toolchain-terraform"
    }
    stages {
        stage('Validate Terraform') {
            steps {
                container('terraform11') {
                    script {
                          sh "make validate"
                    }
                }
            }
        }
    }
}
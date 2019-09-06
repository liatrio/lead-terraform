pipeline {
    agent {
        label "lead-toolchain-terraform"
    }
    stages {
        stage('Validate Terraform') {
            steps {
                container('terraform') {
                    script {
                          sh "make validate"
                    }
                }
            }
        }
    }
}

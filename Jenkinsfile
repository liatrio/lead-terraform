pipeline {
    agent {
        label "lead-toolchain-terraform"
    }
    stages {
        stage('Install Terraform Plugins') {
            steps {
                container('terraform') {
                    script {
                          sh "make plugins"
                    }
                }
            }
        }        
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
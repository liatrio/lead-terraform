library 'LEAD'
pipeline {
    agent {
        label "lead-toolchain-terraform"
    }
    stages {
        stage('Validate Terraform') {
            steps {
                notifyPipelineStart()
                notifyStageStart()                                                                                                                                                                      
                container('terraform') {
                    script {
                          sh "make validate"
                    }
                }
            }
            post {
              success {
                notifyStageEnd()
              }
            failure {
                notifyStageEnd([result: "fail"])
              }
            }
        }
    }
}

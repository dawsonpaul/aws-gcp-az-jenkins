pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('terraform_creds')
    }
    stages {
        withCredentials([sshUserPrivateKey(credentialsId: 'ec2_ssh', keyFileVariable: 'SSH_KEY')]) {
            stage('Terraform_Init') {
                steps {
                    sh 'ls'
                    sh 'terraform init'
                    // SSH_KEY is available here
                }
            }
            stage('Terraform_Plan') {
                steps {
                    sh 'terraform plan'
                    // SSH_KEY is available here too
                }
            }
        }
    }
}
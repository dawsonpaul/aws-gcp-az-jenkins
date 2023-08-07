pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('terraform_creds')
        AZ_CRED = credentials('Azure_Service_Principal')
    }

    stages {
        stage('Credentials') {
            steps {
                script {
                    env.SSH_KEY = sh(script: 'echo $SSH_KEY', returnStdout: true).trim()
                }
            }
        }
        stage('Init1') {
            steps {
                sh 'ls'
                sh 'terraform init'
                // SSH_KEY is available here
            }
        }
        stage('Plan') {
            steps {
                sh 'az login --service-principal -u $AZ_CRED_CLIENT_ID -p $AZ_CRED_CLIENT_SECRET -t $AZ_CRED_TENANT_ID'
                sh 'terraform plan'
                // SSH_KEY is available here too
            }
        }
    }
}

pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('terraform_creds')
        AZURE= credentials('Azure_Service_Principal')
        echo "My client id is $AZURE_CLIENT_ID"
        echo "My client secret is $AZURE_CLIENT_SECRET"
        echo "My tenant id is $AZURE_TENANT_ID"
        echo "My subscription id is $AZURE_SUBSCRIPTION_ID"
    }

    stages {
        stage('Credentials') {
            steps {
                script {
                    env.SSH_KEY = sh(script: 'echo $SSH_KEY', returnStdout: true).trim()
                }
            }
        }
        stage('Terraform_Init') {
            steps {
                sh 'ls'
                sh 'terraform init'
                // SSH_KEY is available here
            }
        }
        stage('Terraform_Plan') {
            steps {
                sh 'AZURE login --service-principal -u $AZURE_CRED_CLIENT_ID -p $AZURE_CRED_CLIENT_SECRET -t $AZURE_CRED_TENANT_ID'
                sh 'terraform plan'
                // SSH_KEY is available here too
            }
        }
    }
}

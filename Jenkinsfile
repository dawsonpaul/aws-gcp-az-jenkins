pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('terraform_creds')
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
                sh 'terraform plan'
                // SSH_KEY is available here too
            }
        }
    }
}

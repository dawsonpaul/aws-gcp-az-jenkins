pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('terraform_creds')
        AZURE= credentials('Azure_Service_Principal')
        EC2_SSH_KEY = credentials('ec2_ssh')
        NGROK_TOKEN = credentials('ngrok_token')
    }

 stages {

        stage('Terraform: Init') {
            steps {

                sh 'terraform init -no-color'
            }
        }
        stage('Terraform: Plan') {
            steps {
                
                sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
                sh 'terraform plan -no-color -var "AZURE_CLIENT_ID=${AZURE_CLIENT_ID}" -var "AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}" -var "AZURE_TENANT_ID=${AZURE_TENANT_ID}" -var "AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}"'

            }
        }

        stage('Terraform: Apply.') {
            steps {
                sh 'terraform apply -auto-approve -no-color -var "AZURE_CLIENT_ID=${AZURE_CLIENT_ID}" -var "AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}" -var "AZURE_TENANT_ID=${AZURE_TENANT_ID}" -var "AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}"'
                script {
                    waflab_vm_ip_address = sh(script: "terraform output waflab_vm_ip_address", returnStdout: true).trim()
                    waflab_appgw_url = sh(script: "terraform output waflab_appgw_url", returnStdout: true).trim()
                }
            }
        }

        stage('Ansible: Deploy OWASP JuiceShop') {
            steps {
                sh "ansible-playbook ./deploy-owasp-juiceshop.yml  -u adminuser --private-key ${EC2_SSH_KEY} --extra-vars 'waflab_vm_ip_address=${waflab_vm_ip_address}'"
            }
        }

        stage('Run GoTestWAF Report') {
            steps {
                sh "docker pull wallarm/gotestwaf:latest"
                sh "docker run --user root --rm --network='host' -v /var/lib/jenkins/reports:/app/reports wallarm/gotestwaf  --reportFormat=html --includePayloads --skipWAFIdentification  --url ${waflab_appgw_url}/#/ " 
           
            }
        }

        stage('Start HTTP Server and ngrok') {
            steps {
                script {
                    def ngrokToken = env.NGROK_TOKEN
                    sh "ansible-playbook ./deploy-http-ngrok.yml -e 'ngrok_token=${ngrokToken}'"
                    sleep 5
                }
            }
        }

        stage('Get ngrok URL') {
            steps {
                    script {
                        def ngrokInfo = sh(script: 'curl -s http://localhost:4040/api/tunnels', returnStdout: true).trim()
                        def url = readJSON text: ngrokInfo
                        echo "ngrok URL: ${url.tunnels[0]?.public_url}"
                    }

                }
        }

        stage('Terraform: Destroy (Optional)') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                script {
                    def shouldDestroy = input(message: 'Do you want to destroy the Terraform resources?', ok: 'Yes', parameters: [booleanParam(defaultValue: false, description: 'Tick for yes', name: 'confirm')])
                    if (shouldDestroy) {
                        sh 'terraform destroy -auto-approve -no-color -var "AZURE_CLIENT_ID=${AZURE_CLIENT_ID}" -var "AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}" -var "AZURE_TENANT_ID=${AZURE_TENANT_ID}" -var "AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}"'
                    }
                }
            }
        }
    
    }

//     post {
//         always {
//             archiveArtifacts artifacts: '*.html', fingerprint: true ----=
//         }
//     }.
}

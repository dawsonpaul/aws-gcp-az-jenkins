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

        stage('Terraform: Apply') {
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

        stage('Start HTTP Server') {
            steps {
                sh 'screen -dm python3 -m http.server 8000 --directory /var/lib/jenkins/reports'
                sleep 5
            }
        }

        stage('Run ngrok and Get URL') {
            steps {
        // Start the ngrok container
                sh "screen -dm docker run --network host -e NGROK_AUTHTOKEN=$NGROK_TOKEN -p 4040:4040 ngrok/ngrok http 172.17.0.1:8000"
                sleep 5 // Allow some time for ngrok to start
                script {
                    // Fetch the ngrok tunnels information. - readJSON needs plugin "Pipeline Utility Steps "
                    def ngrokInfo = sh(script: 'curl -s http://localhost:4040/api/tunnels', returnStdout: true).trim()
                    def url = readJSON text: ngrokInfo
                    echo "ngrok URL: ${url.tunnels[0]?.public_url}"
        }
    }
}
    }
    post {
        always {
            archiveArtifacts artifacts: '*.html', fingerprint: true
        }
    }
}
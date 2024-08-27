pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('terraform_creds')
        AZURE = credentials('Azure_Service_Principal')
        AWS_CREDENTIALS_ID = 'aws-credential' // The ID for AWS credentials stored in Jenkins
        //GCP = credentials('GCP_Credentials')
        EC2_SSH_KEY = credentials('ec2_ssh')
        NGROK_TOKEN = credentials('ngrok_token')
    }

    stages {
        stage('Select Cloud Providers') {
            steps {
                script {
                    def selectedClouds = input message: 'Select Cloud Providers to deploy to:', parameters: [
                        booleanParam(defaultValue: true, description: 'Deploy to Azure', name: 'Azure'),
                        booleanParam(defaultValue: true, description: 'Deploy to AWS', name: 'AWS'),
                        booleanParam(defaultValue: true, description: 'Deploy to GCP', name: 'GCP')
                    ]
                    
                    // Store the selected options in variables
                    env.DEPLOY_AZURE = selectedClouds['Azure'] ? 'true' : 'false'
                    env.DEPLOY_AWS = selectedClouds['AWS'] ? 'true' : 'false'
                    env.DEPLOY_GCP = selectedClouds['GCP'] ? 'true' : 'false'

                    echo "Selected Cloud Providers: Azure=${env.DEPLOY_AZURE}, AWS=${env.DEPLOY_AWS}, GCP=${env.DEPLOY_GCP}"
                }
            }
        }

        stage('Terraform: Init') {
            parallel {
                stage('Init Azure') {
                    when {
                        expression { env.DEPLOY_AZURE == 'true' }
                    }
                    steps {
                        dir('Azure') {
                            sh 'terraform init -no-color'
                        }
                    }
                }
                stage('Init AWS') {
                    when {
                        expression { env.DEPLOY_AWS == 'true' }
                    }
                    steps {
                        dir('AWS') {
                            withAWS(credentials: "${env.AWS_CREDENTIALS_ID}") {
                                sh 'terraform init -no-color'
                            }
                        }
                    }
                }
                stage('Init GCP') {
                    when {
                        expression { env.DEPLOY_GCP == 'true' }
                    }
                    steps {
                        echo "GCP Init stage - Dummy"
                        // Add GCP initialization commands here in the future
                    }
                }
            }
        }

        stage('Terraform: Plan') {
            parallel {
                stage('Plan Azure') {
                    when {
                        expression { env.DEPLOY_AZURE == 'true' }
                    }
                    steps {
                        dir('Azure') {
                            sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
                            sh 'terraform plan -no-color -var "AZURE_CLIENT_ID=${AZURE_CLIENT_ID}" -var "AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}" -var "AZURE_TENANT_ID=${AZURE_TENANT_ID}" -var "AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}"'
                        }
                    }
                }
                stage('Plan AWS') {
                    when {
                        expression { env.DEPLOY_AWS == 'true' }
                    }
                    steps {
                        dir('AWS') {
                            withAWS(credentials: "${env.AWS_CREDENTIALS_ID}") {
                                sh 'terraform plan -no-color'
                            }
                        }
                    }
                }
                stage('Plan GCP') {
                    when {
                        expression { env.DEPLOY_GCP == 'true' }
                    }
                    steps {
                        echo "GCP Plan stage - Dummy"
                        // Add GCP plan commands here in the future
                    }
                }
            }
        }

        stage('Terraform: Apply') {
            parallel {
                stage('Apply Azure') {
                    when {
                        expression { env.DEPLOY_AZURE == 'true' }
                    }
                    steps {
                        dir('Azure') {
                            sh 'terraform apply -auto-approve -no-color -var "AZURE_CLIENT_ID=${AZURE_CLIENT_ID}" -var "AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}" -var "AZURE_TENANT_ID=${AZURE_TENANT_ID}" -var "AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}"'
                            script {
                                waflab_vm_ip_address = sh(script: "terraform output waflab_vm_ip_address", returnStdout: true).trim()
                                waflab_appgw_url = sh(script: "terraform output waflab_appgw_url", returnStdout: true).trim()
                            }
                        }
                    }
                }
                stage('Apply AWS') {
                    when {
                        expression { env.DEPLOY_AWS == 'true' }
                    }
                    steps {
                        dir('AWS') {
                            withAWS(credentials: "${env.AWS_CREDENTIALS_ID}") {
                                sh 'terraform apply -auto-approve -no-color'
                                script {
                                    aws_instance_ip = sh(script: "terraform output ec2_public_ip", returnStdout: true).trim()
                                    aws_lb_dns = sh(script: "terraform output load_balancer_dns", returnStdout: true).trim()
                                }
                            }
                        }
                    }
                }
                stage('Apply GCP') {
                    when {
                        expression { env.DEPLOY_GCP == 'true' }
                    }
                    steps {
                        echo "GCP Apply stage - Dummy"
                        // Add GCP apply commands here in the future
                    }
                }
            }
        }

        stage('Ansible: Deploy OWASP JuiceShop (Azure only)') {
            when {
                expression { env.DEPLOY_AZURE == 'true' }
            }
            steps {
                dir('Azure') {
                    sh "ansible-playbook ./deploy-owasp-juiceshop.yml  -u adminuser --private-key ${EC2_SSH_KEY} --extra-vars 'waflab_vm_ip_address=${waflab_vm_ip_address}'"
                }
            }
        }

        stage('Decide on GoTestWAF Execution') {
            when {
                expression { return env.DEPLOY_AZURE == 'true' || env.DEPLOY_AWS == 'true' || env.DEPLOY_GCP == 'true' }
            }
            steps {
                script {
                    def runGoTestWAF_Azure = false
                    def runGoTestWAF_AWS = false
                    def runGoTestWAF_GCP = false

                    if (env.DEPLOY_AZURE == 'true') {
                        runGoTestWAF_Azure = input(message: 'Run GoTestWAF on Azure?', ok: 'Proceed', parameters: [booleanParam(defaultValue: true, description: 'Run GoTestWAF on Azure?', name: 'RunGoTestWAF_Azure')])
                    }
                    if (env.DEPLOY_AWS == 'true') {
                        runGoTestWAF_AWS = input(message: 'Run GoTestWAF on AWS?', ok: 'Proceed', parameters: [booleanParam(defaultValue: true, description: 'Run GoTestWAF on AWS?', name: 'RunGoTestWAF_AWS')])
                    }
                    if (env.DEPLOY_GCP == 'true') {
                        runGoTestWAF_GCP = input(message: 'Run GoTestWAF on GCP?', ok: 'Proceed', parameters: [booleanParam(defaultValue: true, description: 'Run GoTestWAF on GCP?', name: 'RunGoTestWAF_GCP')])
                    }

                    env.RUN_GOTESTWAF_AZURE = runGoTestWAF_Azure ? 'true' : 'false'
                    env.RUN_GOTESTWAF_AWS = runGoTestWAF_AWS ? 'true' : 'false'
                    env.RUN_GOTESTWAF_GCP = runGoTestWAF_GCP ? 'true' : 'false'
                }
            }
        }

        stage('Run GoTestWAF Report') {
            parallel {
                stage('Test Azure WAF') {
                    when {
                        expression { env.DEPLOY_AZURE == 'true' && env.RUN_GOTESTWAF_AZURE == 'true' }
                    }
                    steps {
                        dir('Azure') { // Use Azure directory for the Azure GoTestWAF report
                            sh "docker pull wallarm/gotestwaf:latest"
                            sh "docker run --user root --rm --network='host' -v /var/lib/jenkins/reports/Azure:/app/reports wallarm/gotestwaf --reportFormat=html --includePayloads=true --skipWAFIdentification --noEmailReport --url ${waflab_appgw_url}/#/"
                        }
                    }
                }
                stage('Test AWS WAF') {
                    when {
                        expression { env.DEPLOY_AWS == 'true' && env.RUN_GOTESTWAF_AWS == 'true' }
                    }
                    steps {
                        dir('AWS') { // Use AWS directory for the AWS GoTestWAF report
                            sh "docker pull wallarm/gotestwaf:latest"
                            sh "docker run --user root --rm --network='host' -v /var/lib/jenkins/reports/AWS:/app/reports wallarm/gotestwaf --reportFormat=html --includePayloads=true --skipWAFIdentification --noEmailReport --url http://${aws_lb_dns}/#/"
                        }
                    }
                }
                stage('Test GCP WAF') {
                    when {
                        expression { env.DEPLOY_GCP == 'true' && env.RUN_GOTESTWAF_GCP == 'true' }
                    }
                    steps {
                        dir('GCP') { // Use GCP directory for the GCP GoTestWAF report
                            echo "GCP GoTestWAF stage - Dummy"
                            // Add GCP GoTestWAF commands here in the future
                        }
                    }
                }
            }
        }

        stage('Start HTTP Server and ngrok') {
            when {
                expression { return env.DEPLOY_AZURE == 'true' || env.DEPLOY_AWS == 'true' || env.DEPLOY_GCP == 'true' }
            }
            steps {
                script {
                    def ngrokToken = env.NGROK_TOKEN
                    sh "ansible-playbook ./deploy-http-ngrok.yml -e 'ngrok_token=${ngrokToken}'"
                    sleep 5
                }
            }
        }

        stage('Get ngrok URL') {
            when {
                expression { return env.DEPLOY_AZURE == 'true' || env.DEPLOY_AWS == 'true' || env.DEPLOY_GCP == 'true' }
            }
            steps {
                script {
                    def ngrokInfo = sh(script: 'curl -s http://localhost:4040/api/tunnels', returnStdout: true).trim()
                    def url = readJSON text: ngrokInfo
                    echo "ngrok URL: ${url.tunnels[0]?.public_url}"
                }
            }
        }

        stage('Prompt for Destroy Confirmation') {
            when {
                expression { return env.DEPLOY_AZURE == 'true' || env.DEPLOY_AWS == 'true' || env.DEPLOY_GCP == 'true' }
            }
            steps {
                script {
                    def parameters = []
                    if (env.DEPLOY_AZURE == 'true') {
                        parameters << booleanParam(defaultValue: false, description: 'Destroy Azure Resources', name: 'Destroy_Azure')
                    }
                    if (env.DEPLOY_AWS == 'true') {
                        parameters << booleanParam(defaultValue: false, description: 'Destroy AWS Resources', name: 'Destroy_AWS')
                    }
                    if (env.DEPLOY_GCP == 'true') {
                        parameters << booleanParam(defaultValue: false, description: 'Destroy GCP Resources', name: 'Destroy_GCP')
                    }

                    def destroyResources = input message: 'Do you want to destroy the Terraform resources for the selected environments?', parameters: parameters

                    // Access the map using bracket notation to avoid MissingPropertyException
                    env.DESTROY_AZURE = destroyResources['Destroy_Azure'] ? 'true' : 'false'
                    env.DESTROY_AWS = destroyResources['Destroy_AWS'] ? 'true' : 'false'
                    env.DESTROY_GCP = destroyResources['Destroy_GCP'] ? 'true' : 'false'
                }
            }
        }

        stage('Terraform: Destroy') {
            when {
                expression { env.DESTROY_AZURE == 'true' || env.DESTROY_AWS == 'true' || env.DESTROY_GCP == 'true' }
            }
            parallel {
                stage('Destroy Azure') {
                    when {
                        expression { env.DESTROY_AZURE == 'true' }
                    }
                    steps {
                        dir('Azure') {
                            sh 'terraform destroy -auto-approve -no-color -var "AZURE_CLIENT_ID=${AZURE_CLIENT_ID}" -var "AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}" -var "AZURE_TENANT_ID=${AZURE_TENANT_ID}" -var "AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}"'
                        }
                    }
                }
                stage('Destroy AWS') {
                    when {
                        expression { env.DESTROY_AWS == 'true' }
                    }
                    steps {
                        dir('AWS') {
                            withAWS(credentials: "${env.AWS_CREDENTIALS_ID}") {
                                sh 'terraform destroy -auto-approve -no-color'
                            }
                        }
                    }
                }
                stage('Destroy GCP') {
                    when {
                        expression { env.DESTROY_GCP == 'true' }
                    }
                    steps {
                        echo "GCP Destroy stage - Dummy"
                        // Add GCP destroy commands here in the future
                    }
                }
            }
        }
    }
}

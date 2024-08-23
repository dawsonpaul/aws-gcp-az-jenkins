pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('terraform_creds')
        AZURE = credentials('Azure_Service_Principal')
        AWS = credentials('AWS_Credentials')
        GCP = credentials('GCP_Credentials')
        EC2_SSH_KEY = credentials('ec2_ssh')
        NGROK_TOKEN = credentials('ngrok_token')
    }

    stages {

        stage('Select Cloud Providers') {
            steps {
                script {
                    def selectedClouds = input message: 'Select Cloud Providers to deploy to:', parameters: [
                        booleanParam(defaultValue: true, description: 'Deploy to Azure', name: 'Azure'),
                        booleanParam(defaultValue: false, description: 'Deploy to AWS', name: 'AWS'),
                        booleanParam(defaultValue: false, description: 'Deploy to GCP', name: 'GCP')
                    ]
                    env.DEPLOY_AZURE = selectedClouds.Azure
                    env.DEPLOY_AWS = selectedClouds.AWS
                    env.DEPLOY_GCP = selectedClouds.GCP
                    echo "Selected Cloud Providers: Azure=${env.DEPLOY_AZURE}, AWS=${env.DEPLOY_AWS}, GCP=${env.DEPLOY_GCP}"
                }
            }
        }

        stage('Terraform: Init') {
            parallel {
                stage('Init Azure') {
                    when {
                        expression { return env.DEPLOY_AZURE == 'true' }
                    }
                    steps {
                        dir('Azure') {
                            sh 'terraform init -no-color'
                        }
                    }
                }
                stage('Init AWS') {
                    when {
                        expression { return env.DEPLOY_AWS == 'true' }
                    }
                    steps {
                        echo "AWS Init stage - Dummy"
                        // Add AWS initialization commands here in the future
                    }
                }
                stage('Init GCP') {
                    when {
                        expression { return env.DEPLOY_GCP == 'true' }
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
                        expression { return env.DEPLOY_AZURE == 'true' }
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
                        expression { return env.DEPLOY_AWS == 'true' }
                    }
                    steps {
                        echo "AWS Plan stage - Dummy"
                        // Add AWS plan commands here in the future
                    }
                }
                stage('Plan GCP') {
                    when {
                        expression { return env.DEPLOY_GCP == 'true' }
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
                        expression { return env.DEPLOY_AZURE == 'true' }
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
                        expression { return env.DEPLOY_AWS == 'true' }
                    }
                    steps {
                        echo "AWS Apply stage - Dummy"
                        // Add AWS apply commands here in the future
                    }
                }
                stage('Apply GCP') {
                    when {
                        expression { return env.DEPLOY_GCP == 'true' }
                    }
                    steps {
                        echo "GCP Apply stage - Dummy"
                        // Add GCP apply commands here in the future
                    }
                }
            }
        }

        stage('Ansible: Deploy OWASP JuiceShop') {
            parallel {
                stage('Deploy on Azure') {
                    when {
                        expression { return env.DEPLOY_AZURE == 'true' }
                    }
                    steps {
                        dir('Azure') {
                            sh "ansible-playbook ./deploy-owasp-juiceshop.yml  -u adminuser --private-key ${EC2_SSH_KEY} --extra-vars 'waflab_vm_ip_address=${waflab_vm_ip_address}'"
                        }
                    }
                }
                stage('Deploy on AWS') {
                    when {
                        expression { return env.DEPLOY_AWS == 'true' }
                    }
                    steps {
                        echo "AWS Ansible stage - Dummy"
                        // Add AWS Ansible commands here in the future
                    }
                }
                stage('Deploy on GCP') {
                    when {
                        expression { return env.DEPLOY_GCP == 'true' }
                    }
                    steps {
                        echo "GCP Ansible stage - Dummy"
                        // Add GCP Ansible commands here in the future
                    }
                }
            }
        }

        stage('Decide on GoTestWAF Execution') {
            when {
                expression { return env.DEPLOY_AZURE == 'true' || env.DEPLOY_AWS == 'true' || env.DEPLOY_GCP == 'true' }
            }
            steps {
                script {
                    def parameters = []
                    if (env.DEPLOY_AZURE == 'true') {
                        parameters << booleanParam(defaultValue: true, description: 'Run GoTestWAF on Azure', name: 'RunGoTestWAF_Azure')
                    }
                    if (env.DEPLOY_AWS == 'true') {
                        parameters << booleanParam(defaultValue: false, description: 'Run GoTestWAF on AWS', name: 'RunGoTestWAF_AWS')
                    }
                    if (env.DEPLOY_GCP == 'true') {
                        parameters << booleanParam(defaultValue: false, description: 'Run GoTestWAF on GCP', name: 'RunGoTestWAF_GCP')
                    }

                    def runGoTestWAF = input message: 'Do you want to run GoTestWAF against the selected environments?', parameters: parameters

                    if (env.DEPLOY_AZURE == 'true') {
                        env.RUN_GOTESTWAF_AZURE = runGoTestWAF['RunGoTestWAF_Azure']
                    }
                    if (env.DEPLOY_AWS == 'true') {
                        env.RUN_GOTESTWAF_AWS = runGoTestWAF['RunGoTestWAF_AWS']
                    }
                    if (env.DEPLOY_GCP == 'true') {
                        env.RUN_GOTESTWAF_GCP = runGoTestWAF['RunGoTestWAF_GCP']
                    }
                }
            }
        }

        stage('Run GoTestWAF Report') {
            parallel {
                stage('Test Azure WAF') {
                    when {
                        expression { return env.DEPLOY_AZURE == 'true' && env.RUN_GOTESTWAF_AZURE == 'true' }
                    }
                    steps {
                        sh "docker pull wallarm/gotestwaf:latest"
                        sh "docker run --user root --rm --network='host' -v /var/lib/jenkins/reports:/app/reports wallarm/gotestwaf --reportFormat=html --includePayloads=true --skipWAFIdentification --noEmailReport --url ${waflab_appgw_url}/#/"
                    }
                }
                stage('Test AWS WAF') {
                    when {
                        expression { return env.DEPLOY_AWS == 'true' && env.RUN_GOTESTWAF_AWS == 'true' }
                    }
                    steps {
                        echo "AWS GoTestWAF stage - Dummy"
                        // Add AWS GoTestWAF commands here in the future
                    }
                }
                stage('Test GCP WAF') {
                    when {
                        expression { return env.DEPLOY_GCP == 'true' && env.RUN_GOTESTWAF_GCP == 'true' }
                    }
                    steps {
                        echo "GCP GoTestWAF stage - Dummy"
                        // Add GCP GoTestWAF commands here in the future
                    }
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

                    if (env.DEPLOY_AZURE == 'true') {
                        env.DESTROY_AZURE = destroyResources['Destroy_Azure']
                    }
                    if (env.DEPLOY_AWS == 'true') {
                        env.DESTROY_AWS = destroyResources['Destroy_AWS']
                    }
                    if (env.DEPLOY_GCP == 'true') {
                        env.DESTROY_GCP = destroyResources['Destroy_GCP']
                    }
                }
            }
        }

        stage('Terraform: Destroy') {
            when {
                expression { return env.DESTROY_AZURE == 'true' || env.DESTROY_AWS == 'true' || env.DESTROY_GCP == 'true' }
            }
            parallel {
                stage('Destroy Azure') {
                    when {
                        expression { return env.DESTROY_AZURE == 'true' }
                    }
                    steps {
                        dir('Azure') {
                            sh 'terraform destroy -auto-approve -no-color -var "AZURE_CLIENT_ID=${AZURE_CLIENT_ID}" -var "AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}" -var "AZURE_TENANT_ID=${AZURE_TENANT_ID}" -var "AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}"'
                        }
                    }
                }
                stage('Destroy AWS') {
                    when {
                        expression { return env.DESTROY_AWS == 'true' }
                    }
                    steps {
                        echo "AWS Destroy stage - Dummy"
                        // Add AWS destroy commands here in the future
                    }
                }
                stage('Destroy GCP') {
                    when {
                        expression { return env.DESTROY_GCP == 'true' }
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
//
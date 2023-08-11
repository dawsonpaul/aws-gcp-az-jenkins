pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('terraform_creds')
        AZURE= credentials('Azure_Service_Principal')
        EC2_SSH_KEY = credentials('ec2_ssh')
    }

    stages {
        stage('Credentials') {
            steps {
                script {
                    env.SSH_KEY = sh(script: 'echo $SSH_KEY', returnStdout: true).trim()
                }
                echo "My client id is $AZURE_CLIENT_ID"
                echo "My client secret is $AZURE_CLIENT_SECRET"
                echo "My tenant id is $AZURE_TENANT_ID"
                echo "My subscription id is $AZURE_SUBSCRIPTION_ID"
            }
        }
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
                    // Capture the IP address of the VM
                    waflab_vm_ip_address = sh(script: "terraform output waflab_vm_ip_address", returnStdout: true).trim()
                    waflab_lb_ip_address = sh(script: "terraform output waflab_lb_ip_address", returnStdout: true).trim()
                }
            }
        }

        stage('Ansible: Deploy DVWA') {
            steps {
                // Run Ansible playbook, passing the VM IP as an extra variable
                sh "ansible-playbook ./deploy-owasp-juiceshop.yml  -u adminuser --private-key ${EC2_SSH_KEY} --extra-vars 'waflab_vm_ip_address=${waflab_vm_ip_address}'"
            }
        }

        stage('Run gotestwaf') {
            steps {
                sh "docker pull wallarm/gotestwaf:latest"
                // Run gotestwaf against the Load Balancer IP
                sh "docker run --rm --network='host' -it -v $PWD/reports:app/reports wallarm/gotestwaf --url http://${waflab_lb_ip_address}"
                // Change the path to the actual report file location
                script {
                    sh "mv -f $PWD/reports $WORKSPACE"
                }
            }
        }
    }

    post {
        always {
            // Archive the report as an artifact
            archiveArtifacts artifacts: 'report.txt', fingerprint: true
        }
    }
}
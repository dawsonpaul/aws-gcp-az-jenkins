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
                sh 'ls'
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
                }
            }
        }

        stage('Ansible: Deploy DVWA') {
            steps {
                // Run Ansible playbook, passing the VM IP as an extra variable
                sh "ansible-playbook ./deploy-dvwa.yml  -u ubuntu --private-key ${EC2_SSH_KEY} --extra-vars 'waflab_vm_ip_address=${waflab_vm_ip_address}' -vvvv"
            }
        }
    }
}

// pipeline {
//     agent any

//     stages {
//         stage('Terraform: Provision VM') {
//             steps {
//                 // Run Terraform scripts
//                 sh 'terraform init'
//                 sh 'terraform apply -auto-approve'
//                 script {
//                     // Capture the IP address of the VM
//                     vm_ip = sh(script: "terraform output vm_ip", returnStdout: true).trim()
//                 }
//             }
//         }

//         stage('Ansible: Deploy DVWA') {
//             steps {
//                 // Run Ansible playbook, passing the VM IP as an extra variable
//                 sh "ansible-playbook deploy-dvwa.yml --extra-vars 'target_host=${vm_ip}'"
//             }
//         }
//     }
// }



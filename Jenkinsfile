pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['Apply', 'Destroy'], description: 'Choose Terraform action')
    }

    stages {
        stage ("Clean Up"){            
            steps {                    
                deleteDir()            
            }
        }

        stage("Clone Repo"){
            steps {
                sh "git clone https://github.com/dracaruss/Apache-EC2-Server-Setup.git"
            }
        }

        stage("Restore State File") {
            steps {
                script {
                    // Check if the state file exists in the specified directory
                    if (fileExists('/home/jenkinsState/ec2webserver/terraform.tfstate')) {
                        echo "Restoring Terraform state file..."
                        sh 'cp /home/jenkinsState/ec2webserver/terraform.tfstate Apache-EC2-Server-Setup/terraform.tfstate'
                    } else {
                        echo "No Terraform state file found. First run likely."
                    }
                }
            }
        }

        stage("Terraform Init") {
            steps {
                dir('Apache-EC2-Server-Setup') {
                    sh 'terraform init'
                }
            }
        }

        stage("Terraform Plan") {
            steps {
                dir('Apache-EC2-Server-Setup') {
                    sh 'terraform plan'
                }
            }
        }

        stage("Terraform Apply/Destroy") {
            steps {
                dir('Apache-EC2-Server-Setup') {
                    script {
                        if (params.ACTION == 'Apply') {
                            sh 'terraform apply -auto-approve'
                        } else if (params.ACTION == 'Destroy') {
                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
        }

        stage("Save State File") {
            steps {
                dir('Apache-EC2-Server-Setup') {
                    script {
                        // Save the Terraform state file to the specified directory
                        if (fileExists('terraform.tfstate')) {
                            echo "Saving Terraform state file..."
                            sh 'cp terraform.tfstate /home/jenkinsState/ec2webserver/'
                        }
                        else {
                            echo "No Terraform state file to save."
                        }
                    }
                }
            }
        }
    }
}

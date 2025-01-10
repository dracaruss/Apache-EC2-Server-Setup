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
    }
}

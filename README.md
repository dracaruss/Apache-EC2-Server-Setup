# Apache-EC2-Server-Setup

Russell Alexander here!

Follow me as I demonstrate how to set up an Apache web server on EC2 in AWS in 3 different ways. 
First through the AWS console.
Second by terraform.
Third by using Jenkins to automate the terraform and entire workflow.

##

PART 1: AWS CONSOLE SETUP:

![management logo](https://github.com/user-attachments/assets/a98c57d2-686a-4e41-a2eb-cddb53a8ac3f)
##
First create an EC2 instance in AWS using the console, using a pre made VPC. In this VPC make I made sure to add an Internet Gateway and configure the Route Tables to allow connectivity to the internet for the EC2 in the public subnet. Also configure the NACLS and SGs to allow internet access on HTTP (80) and HTTPS (443).

![3  ec2 SC rules](https://github.com/user-attachments/assets/c46091b1-6f93-44f5-b19e-29fa7013ae20)

I leave these ports open to the public since I am using this instance as a web server.

![1  ec2_creation](https://github.com/user-attachments/assets/a7c76a55-b2a1-416e-9de2-45b66072d06b)

After being deployed, double check the settings and take note of the public IP for use later on.

![2  ec2 settings](https://github.com/user-attachments/assets/bec4979e-3e80-4eba-9b0b-7adeeabf0fca)

Confirm that my EC2 is able to access the internet with the Reachablity Analyzer. First from the EC2's ENI, through the SG's and then the ACL's, through the Routing Table and the to my Internet Gateway. Since everything is working as expected I can proceed.

![4  reachability analyzer details for ec2](https://github.com/user-attachments/assets/81b56cec-39a2-44f3-83f3-3e024503a32b)

Now to deploy the Apache web server on the EC2, I navigate to EC2 Connect function of the console and access the Linux CLI of my EC2.

![5  ec2 connect](https://github.com/user-attachments/assets/1ef17562-b012-424b-8ef0-1c988be855bd)

To install the web server, run the script (in my repo) to download, install, and configure the Apache server.
https://github.com/dracaruss/Apache-EC2-Server-Setup/blob/7c47e0bb035eba00e286f2f688e807b83c21d6b4/Apache-Script

First create a pick-a-name.sh file on the instance:
  
	nano pick-a-name.sh

Give it executable ability with:

	chmod +x pick-a-name.sh
  
Then paste in the Apache script from my repo, and save and run the script to launch the Apache web server on the instance:

	./pick-a-name.sh

![6  Install apache server](https://github.com/user-attachments/assets/8edfb6d8-082c-4293-a582-90212863b27a)

Once deployed, use the public IP of the EC2 to access the web page using http (not https) on port 80 from the browser.

![8  web server 2 launched](https://github.com/user-attachments/assets/e5b51c16-2baa-48fb-947b-c398a4ffa73b)

Working as expected!

That's the process I used to configure the web server by using the AWS console, so now onto doing it the second way using terraform IAC.

##

PART 2: TERRAFORM SETUP:

![proxy-image (1)](https://github.com/user-attachments/assets/8641d8ea-f518-47d2-a793-f1485d18f3e3)
##

First let's install terraform, via my Linux VM on my Windows 10. I am most comfortable with Kali but in this case I am using a vanilla Ubuntu.
To install terraform I run these commands to download it, unzip it and then move it into the PATH so I can call it globally.

	sudo apt update && sudo apt install -y wget unzip                                
	wget https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip
	unzip terraform_1.5.5_linux_amd64.zip
	sudo mv terraform /usr/local/bin/
	terraform -v

![1 get terraform installed](https://github.com/user-attachments/assets/d2a69a03-111c-441d-92d1-7f012a2f5aa8)

I got terraform 1.55 purposely, because it's the last version that was then forked to OpenTofu, before IBM took over Hashicorp. 
I did that to keep it as widely compatible as possible.

Then I had to install the AWS CLI on my VM, to interface with AWS.

	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install

![2 install the aws cli](https://github.com/user-attachments/assets/8d6b8c7c-8ba1-4d73-a0bf-baaa1086d85b)

Next was to configure the AWS CLI with the credentials and details for the connection.
Log into the console, go to the user you want to use and get your access key and secret.
I used an admin user since I want to do such a wide range of things with terraform.

	aws configure 

And also to verify the CLI connection is up and running and good to go.

	aws sts get-caller-identity 

Now to install VSCode for Linux.
First download the package from the website:

	https://code.visualstudio.com/download

Then move it to my terraform folder:

	cp /home/beowubuntu/Downloads/code_1.96.2-1734607745_amd64.deb .

Then install it:

	sudo apt install ./code_1.96.2-1734607745_amd64.deb

![3 Install VSCode for linux](https://github.com/user-attachments/assets/ec97e929-5453-4edc-9b71-817d0cf74fff)

Time to launch VSCode and construct my terraform AWS Infrastructure!
*Note: remember to install the terraform VSCode plugin! Brackets won’t color without it

I wanted to check what was the latest terraform provider version, to explicitly state it in my required_providers to maintain future stability:

	https://registry.terraform.io/providers/hashicorp/aws/latest

Time to create the main.tf and configure the VPC:
	
	terraform {
	  required_providers {
	    aws = {
	      source  = "hashicorp/aws"
	      version = "5.82.2"
	    }
	  }
	}
	
	provider "aws" {
	  region = "us-east-1"
	}
	
	resource "aws_vpc" "EC2-webserver-vpc" {
	  cidr_block = "10.0.0.0/24"
	
	  tags = {
	    Name = "main"
	  }
	}

Confirm in the console its creation:

![5 apply the vpc via terraform](https://github.com/user-attachments/assets/b801230f-b12e-4977-abde-d12a6f982c68)

Next to create a public subnet:
	
	resource "aws_subnet" "public_subnet_russ1" {
	  vpc_id     = aws_vpc.EC2-webserver-vpc.id
	  cidr_block = "10.0.0.128/25"
	
	  tags = {
	    Name = "Public and only subnet"
	  }
	}

![6 create public subnet](https://github.com/user-attachments/assets/9ea3a1ec-e48b-4d46-952b-1edc9c7f1391)

And then install the Interney Gateway to give the VPC internet access:

	Install my Internet Gateway:
	resource "aws_internet_gateway" "igw_russ" {
	  vpc_id = aws_vpc.EC2-webserver-vpc.id
	}

![6 5 igw configured and vpc attached](https://github.com/user-attachments/assets/4cbfdd31-8600-42cb-8e8b-67796ed6ccfd)
(Note the VPC is also attached)

Hmmm I had a route table already associated with the VPC when I applied and checked my infrasctructure in the console. (I'm not sure if it was created with the VPC or if I had it there from a previous config). 
I therefore had to import it into my state and add it to my main.tf.

UI added the config to the main.tf:

	resource "aws_route_table" "vpc_route_table" {
	  vpc_id = aws_vpc.EC2-webserver-vpc.id
	
	  route {
	    cidr_block = "0.0.0.0/0"
	    gateway_id = aws_internet_gateway.igw_russ.id
	  }
	}

Then imported the VPC via the CLI:

	terraform import aws_route_table.vpc_route_table rtb-01eee8b6a672f0d54

![7 import route table](https://github.com/user-attachments/assets/eeb43b65-f8c4-4584-b3d3-3a2552c0baaa)

Import successful, ok great moving on!

The route table configuration needed to be applied to the route table next:

	resource "aws_route_table_association" "give_public_internet" {
	  subnet_id      = aws_subnet.public_subnet_russ1.id
	  route_table_id = aws_route_table.vpc_route_table.id
	}

![8 create route table associations](https://github.com/user-attachments/assets/d7dfabdf-05da-4a1e-bba2-85c7e64ebff1)

Subnets now have internet access!:

![9 subnets now have internet access](https://github.com/user-attachments/assets/7b34bb8f-a461-4dc9-87b0-6fcf9c64edd4)

Before I launch my EC2 I need to setup a security group to associate with it.
First I need my IP to associate with the SSH access.
From the AWS CLI:

	curl https://checkip.amazonaws.com

(I also checked in the console while going through the steps to create an EC2 and grabbed the AMI)

Ok now to setup my Security Group:

	resource "aws_security_group" "secgroup1-russ" {
	  name = "webserver_access"
	  vpc_id      =  aws_vpc.EC2-webserver-vpc.id
	
	ingress {
	    from_port   = 22
	    to_port     = 22
	    protocol    = "tcp"
	    cidr_blocks = ["0.0.0.0/0"]
	  }
	  ingress {
	    from_port   = 80
	    to_port     = 80
	    protocol    = "tcp"
	    cidr_blocks = ["0.0.0.0/0"]
	  }
	    ingress {
	    from_port   = 443
	    to_port     = 443
	    protocol    = "tcp"
	    cidr_blocks = ["0.0.0.0/0"]
	  }
	  # Outbound rule allowing all outbound traffic
	  egress {
	    from_port   = 0
	    to_port     = 0
	    protocol    = "-1"          # -1 means all protocols
	    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to anywhere
	  }
	}

I also need to create a key pair for the EC2:

	resource "tls_private_key" "privatekey-ec2-webserver" {
	  algorithm = "RSA"
	  rsa_bits  = 2048
	}
	
	resource "aws_key_pair" "ec2-public-key" {
	  key_name   = "ec2-public-key-webserver"
	  public_key = tls_private_key.privatekey-ec2-webserver.public_key_openssh
	}

This gave me an error since it needed the tls provider which I didn’t originally add to my main.tf, Oops.

First I used 

	terraform init -upgrade 

to get my backend configured with the needed tls provider.

Then I explicitly added the tls provider to the main.tf, and specified the version in the terraform block.

	terraform {
	  required_providers {
	    aws = {
	      source  = "hashicorp/aws"
	      version = "5.82.2"
	    }
	    tls = {
	      source  = "hashicorp/tls"
	      version = "4.0.6"
	    }
	  }
	}
	
	provider "aws" {
	  region = "us-east-1"
	}
	
	provider "tls" {} # adding the missing provider
	
	To download the private.pem file I added:
	
	# Save the private key to a file
	resource "local_file" "private_ec2_key" {
	  content  = tls_private_key.privatekey-ec2-webserver.private_key_pem
	  filename = "ec2_webserver.pem"
	  provisioner "local-exec" {
	    command = "chmod 600 ec2_webserver.pem"
	  }
	}

This also failed because I didn’t add the ‘local’ provider (face palm), so I explicitly did that with the version for future stability:

	terraform {
	  required_providers {
	    aws = {
	      source  = "hashicorp/aws"
	      version = "5.82.2"
	    }
	    tls = {
	      source  = "hashicorp/tls"
	      version = "4.0.6" 
	    }
	    local = {
	      source  = "hashicorp/local"
	      version = "2.5.2"
	    }
	  }
	}
	
	provider "aws" {
	  region = "us-east-1"
	}
	
	provider "tls" {}
	
	provider "local" {}

After running a new init and plan I am good to go!

Now that the backing infrastructure is finally setup, it’s time to provision the EC2 that will host the Apache web server:
##
	resource "aws_instance" "ecX-terraform" {
	  ami           = "ami-01816d07b1128cd2d"
	  instance_type = "t2.micro"
	  key_name      = "ec2-public-key-webserver"
	  subnet_id     = aws_subnet.public_subnet_russ1.id
	
	  vpc_security_group_ids = [
	    aws_security_group.secgroup1-russ.id
	  ]
	}

Ok applied and everything is great! 
Now finally and lastly it’s time to configure my Apache webserver!

I added the user_data sectino to the EC2 instance block, to install the apache web server via yum on the AWS Linux EC2 
(I made an initial mistake and used apt instead of yum 😀, I guess I am too used to Ubuntu and Kali!)
##
	resource "aws_instance" "ecX-terraform" {
	  ami           = "ami-01816d07b1128cd2d"
	  instance_type = "t2.micro"
	  key_name      = "ec2-public-key-webserver"
	  subnet_id     = aws_subnet.public_subnet_russ1.id
	
	  vpc_security_group_ids = [
	    aws_security_group.secgroup1-russ.id
	  ]
	
	  associate_public_ip_address = true # This ensures a public IP is assigned
	
	  user_data = <<-EOF
	    #!/bin/bash
	        sudo yum update -y
	        sudo yum install httpd -y
	        sudo systemctl start httpd
	        sudo systemctl enable httpd
	        echo "<html><body><h1>This is Russell's Apache website!</h1></body></html>" > /var/www/html/index.html
	        sudo systemctl restart httpd
	    EOF
	}

And here we are again, my apache web server is up and running like before, only this time with Terraform!

![8  web server 2 launched](https://github.com/user-attachments/assets/21242639-7e53-4d28-8124-9e59b85ee879)

Now to apply some automation with Jenkins and git for the last phase.

##

PART 3: JENKINS AUTOMATION WITH GIT:
##


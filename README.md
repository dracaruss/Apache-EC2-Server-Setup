# Apache-EC2-Server-Setup

Russell Alexander here!

Follow me as I demonstrate how to set up an Apache web server on EC2 in AWS in 3 different ways. 
First through the AWS console.
Second by terraform.
Third by using Jenkins to automate the terraform and entire workflow.

##

CONSOLE SETUP:

![management logo](https://github.com/user-attachments/assets/a98c57d2-686a-4e41-a2eb-cddb53a8ac3f)

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

TERRAFORM SETUP:

![proxy-image (1)](https://github.com/user-attachments/assets/8641d8ea-f518-47d2-a793-f1485d18f3e3)

First let's install terraform, via my linux VM on my Windows 10. I am most comfortable with Kali but in this case I am using a vanilla Ubuntu.
To install terraform I run these commands to download it, unzip it and then move it into the PATH so I can call it globally.

	sudo apt update && sudo apt install -y wget unzip                                
	wget https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip
	unzip terraform_1.5.5_linux_amd64.zip
	sudo mv terraform /usr/local/bin/
	terraform -v

![1 get terraform installed](https://github.com/user-attachments/assets/d2a69a03-111c-441d-92d1-7f012a2f5aa8)

I got terraform 1.55 purposely, because it's the last version that was then forked to OpenTofu, before IBM took over Hashicorp. 
I did that to keep it as widely compatible as possible.

Then I had to install the AWS CLi on my VM, to interface with AWS.

	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install

![2 install the aws cli](https://github.com/user-attachments/assets/8d6b8c7c-8ba1-4d73-a0bf-baaa1086d85b)

Next was to configure the AWS CLi with the credentials and details for the connection.

	aws configure 

And also to verify the CLi connection is up and running and good to go.

	aws sts get-caller-identity 

Now to install VSCode for linux.
First download the package from the website:

	https://code.visualstudio.com/download

Then move it to my terraform folder:

	cp /home/beowubuntu/Downloads/code_1.96.2-1734607745_amd64.deb .

Then install it:

	sudo apt install ./code_1.96.2-1734607745_amd64.deb






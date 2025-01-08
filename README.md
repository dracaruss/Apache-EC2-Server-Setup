# Apache-EC2-Server-Setup

I'll demonstrate how I set up an Apache web server on EC2 in AWS in 3 different ways. 
First through the AWS console.
Second by terraform.
Third by using Jenkins to automate the terraform and entire workflow.

First create an EC2 instance in AWS using the console, using a pre made VPC. In this VPC make I made sure to add an Internet Gateway and configure the Route Tables to allow connectivity to the internet for the EC2 in the public subnet. Also configure the NACLS and SGs to allow internet access on HTTP (80) and HTTPS (443).
![3  ec2 SC rules](https://github.com/user-attachments/assets/c46091b1-6f93-44f5-b19e-29fa7013ae20)

I leave these ports open to the public since I am using this instance as a web server.

![1  ec2_creation](https://github.com/user-attachments/assets/a7c76a55-b2a1-416e-9de2-45b66072d06b)

After being deployed, double check the settings and take note of the public IP for use later on.

![2  ec2 settings](https://github.com/user-attachments/assets/bec4979e-3e80-4eba-9b0b-7adeeabf0fca)

Confirm that my EC2 is able to access my Internet Gateway and everything is working as expected with connectivity with the Reachablity Analyzer.
![4  reachability analyzer details for ec2](https://github.com/user-attachments/assets/81b56cec-39a2-44f3-83f3-3e024503a32b)

Now to deploy the Apache web server on the EC2, navigate to EC2 connect and access the CLI of the EC2.
![5  ec2 connect](https://github.com/user-attachments/assets/1ef17562-b012-424b-8ef0-1c988be855bd)

Run the script in my repo to download, install, and cofigure the Apache server.
![6  Install apache server](https://github.com/user-attachments/assets/8edfb6d8-082c-4293-a582-90212863b27a)
a3b5-ad40ae65b02c)

Once deployed, use the public IP from the EC2 configuration page to now access the web server from port 80 or 443 from the browser.
![7  web server launched](https://github.com/user-attachments/assets/3606f646-7f27-4aaa-95f9-05f8f878db10)

That's the process I used to configure the web server by using the AWS console, so now onto doing it the second way using terraform IAC.

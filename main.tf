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

resource "aws_vpc" "EC2-webserver-vpc" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet_russ1" {
  vpc_id                  = aws_vpc.EC2-webserver-vpc.id
  cidr_block              = "10.0.0.128/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public and only subnet"
  }
}

resource "aws_internet_gateway" "igw_russ" {
  vpc_id = aws_vpc.EC2-webserver-vpc.id
}

resource "aws_route_table" "vpc_route_table" {
  vpc_id = aws_vpc.EC2-webserver-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_russ.id
  }
}

resource "aws_route_table_association" "give_public_internet" {
  subnet_id      = aws_subnet.public_subnet_russ1.id
  route_table_id = aws_route_table.vpc_route_table.id
}

resource "aws_security_group" "secgroup1-russ" {
  name   = "webserver_access"
  vpc_id = aws_vpc.EC2-webserver-vpc.id


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

resource "tls_private_key" "privatekey-ec2-webserver" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2-public-key" {
  public_key = tls_private_key.privatekey-ec2-webserver.public_key_openssh
}

# Save the private key to a file
resource "local_file" "private_ec2_key" {
  content  = tls_private_key.privatekey-ec2-webserver.private_key_pem
  filename = "ec2_webserver.pem"
  provisioner "local-exec" {
    command = "chmod 600 ec2_webserver.pem"
  }
}

resource "aws_instance" "ecX-terraform" {
  ami           = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2-public-key.key_name
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

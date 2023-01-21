/*Deploy an EC2 instance inside a VPC. 

Deliverables

    Create your custom VPC
    Launch your ec2 instance inside the custom VPC.
    Configure your EC2 instance
    Create your public subnet
    Add user data
    Attach the security groups to the ec2 instance created
    View your website */

provider "aws" {
  region = "us-west-2"

}

#create a custom VPC

resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc_id
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "name" = "main"
  }

}

#create and configure the subnets and availability zones

#Public subnet

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "10.0.1.0/24-public_subnet"
  }
}

#Private subnet

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "10.0.2.0/24-private_subnet"
  }
}

#create and configure the EC2 instance using public subnet

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "deployment_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "deployment_instance"
  }
}
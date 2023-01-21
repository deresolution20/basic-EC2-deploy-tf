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
  cidr_block        = var.sub_cidr.public.ip
  availability_zone = var.sub_cidr.public.az

  tags = {
    Name = "${var.sub_cidr.public.ip}-public_subnet"
  }
}

#Private subnet

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.sub_cidr.private.ip
  availability_zone = var.sub_cidr.private.az

  tags = {
    Name = "${var.sub_cidr.private.ip}-private_subnet"
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
  count = 1
  vpc_security_group_ids

  tags = {
    Name = "deployment_instance-${var.environment[0]}"
  }

  depends_on = [aws_internet_gateway.aws_igw]
}

#creating the igw and route table


resource "aws_internet_gateway" "aws_igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "aws igw for ${var.environment[0]} Ec2 instance"
  }
}

resource "aws_route_table" "aws_rtb" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = var.sub_cidr.public.ip
    gateway_id = aws_internet_gateway.aws_igw.id
  }

  tags = {
    Name = "aws rtb for ${var.environment[0]} environment"
  }
}

#creating the security group for public subnet

resource "aws_security_group" "public_sg" {
  name        = "public security group"
  description = "Allow EC2 inbound traffic for ${var.environment[0]} server"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "EC2 from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main-vpc.cidr_block]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "public_sg"
  }
}


#creating the security group for private subnet

resource "aws_security_group" "private_sg" {
  name        = "private security group"
  description = "Allow EC2 inbound traffic for ${var.environment[0]} server"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "EC2 from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main-vpc.cidr_block]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "private_sg"
  }
}
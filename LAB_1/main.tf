provider "aws" {
  shared_config_files = [ "~/.aws/config" ]
  shared_credentials_files = [ "~/.aws/credentials" ]
  region = "us-east-1"
  profile = "default"
}


resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet.id
  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd
    service httpd start
  EOF
  
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  default = "10.0.0.0/24"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "ami_id" {
  default = "ami-0b5eea76982371e91"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "username" {
  default = "ec2-user"
}
provider "aws" {
  shared_config_files = [ "~/.aws/config" ]
  shared_credentials_files = [ "~/.aws/credentials" ]
  region = "us-east-1"
  profile = "default"
}



resource "aws_vpc" "vpc-lab2" {

    cidr_block = var.vpc-cidr
  
}




resource "aws_subnet" "sub-lab2" {

    vpc_id = aws_vpc.vpc-lab2.id
    cidr_block = var.cidr-lab2[count.index]
    count = length(var.cidr-lab2)
    
    # To make first subnet public and second private  
    map_public_ip_on_launch = count.index == 0 ? true : false

}


resource "aws_instance" "EC2" {

    count = 2 
    subnet_id = aws_subnet.sub-lab2[count.index].id
    ami = var.ami-ec2 
    instance_type = var.ec2-type
    associate_public_ip_address = aws_subnet.sub-lab2[count.index].map_public_ip_on_launch
    user_data = <<-EOF
    #!/bin/bash
     sudo apt update -y 
     sudo apt install -y apache2
     sudo systemctl start apache2
  EOF

}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-lab2.id
}


resource "aws_eip" "eip" {

  vpc = true
  depends_on = [
    aws_internet_gateway.igw
  ]


}


resource "aws_nat_gateway" "nat" {

    subnet_id = aws_subnet.sub-lab2[0].id 
    allocation_id = aws_eip.eip.id
    
}


resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc-lab2.id
  route {
    cidr_block = var.pub-rt
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.sub-lab2[0].id
    route_table_id = aws_route_table.public-rt.id
  
}

resource "aws_route_table" "private-rt" {

    vpc_id = aws_vpc.vpc-lab2.id
    route {
        cidr_block = var.pub-rt
        nat_gateway_id = aws_nat_gateway.nat.id
    }
  
}


resource "aws_route_table_association" "private" {

    subnet_id = aws_subnet.sub-lab2[1].id
    route_table_id = aws_route_table.private-rt.id
  
}

######################## VPC CREATION ########################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform-VPC"
  }
}
######################### SUBNET ASSOCIATION ##################
resource "aws_subnet" "Public-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public-Subnet-1"
  }
}
resource "aws_subnet" "Public-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Public-Subnet-2"
  }
}
resource "aws_subnet" "Private-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Private-Subnet-1"
  }
}
resource "aws_subnet" "Private-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Private-Subnet-2"
  }
}
########################## INTERNET GATEWAY ##################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
  }
}
########################## ELASTIC IP ##########################
resource "aws_eip" "EIP" {
  vpc = true
}
########################## NAT GATEWAY ##########################
resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.Public1.id

  tags = {
    Name = "NGW"
  }
}
############################ ROUTE TABLE AND ASSOCIATION #########
resource "aws_route_table" "Public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "Public-rt"
  }
}
resource "aws_route_table" "Private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT.id
  }
  tags = {
    Name = "Private-rt"
  }
}
resource "aws_route_table_association" "Public1" {
  subnet_id      = aws_subnet.Public1.id
  route_table_id = aws_route_table.Public.id
}
resource "aws_route_table_association" "Public2" {
  subnet_id      = aws_subnet.Public2.id
  route_table_id = aws_route_table.Public.id
}
resource "aws_route_table_association" "Private1" {
  subnet_id      = aws_subnet.Private1.id
  route_table_id = aws_route_table.Private.id
}
resource "aws_route_table_association" "Private2" {
  subnet_id      = aws_subnet.Private2.id
  route_table_id = aws_route_table.Private.id
}
####################### CREATING SECURITY GROUP ###############
resource "aws_security_group" "SG-Automation" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from anywhere"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Automation"
  }
}



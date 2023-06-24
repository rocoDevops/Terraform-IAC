######################## VPC CREATION ########################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform-VPC"
    Company = var.Company
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
###################### KEY PAIR ##########################
resource "aws_key_pair" "Terra-key" {
  key_name   = "Terra-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcaUnrTwzEG9fxyZUCowMB/Kc3BqRCq+amk73YKfvPQRcXgLTbKhycIR5EIM5hXm3DZW28JZ64K1mN294t24Klc4grY+Je1pBeHLqK84vaPzFxJ73dPvvNvrtKDSyUQlf03HuWDDrlWBjpam9Z6eodr8XtSvAumKLku1Jxdikvw9Wb9xAOlxhYiKzQZSRUn5bMTzi/Nj4HIHE/+7EEEg2HJM8ID5bB8jXohDMz+q0SX5OfjduYDsp5byVN7+dj1SLRnjY5TKz8/mC+bfcNDDV/S6FUPG/7X2lJh3MEcIb6n3baI5L29ROq/K3FUruZfR35198xHRzRA9q94G1SYSD0STn8spoq23a2ZqLT6jX2r+VFU6kAIbYLNqJPfMabfvvm7MhoVu9i+m+L8ga7GGSagWrYQpfoPMnc7ks0iEIWntQpZHH5OalA7a2n9mWrKlmR9dF7sD7TfErc8jndx2ezbwWqZ9/mxujtbhONxURAePudA3ffwmO0e9C1dSmYXaU= ubuntu@ip-172-31-21-116"
}
####################### INSTANCE CREATION ######################
resource "aws_instance" "Terra-Server" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.small"
  key_name = aws_key_pair.Terra-key.key_name
  subnet_id = aws_subnet.Public-1.id
  security_groups = [aws_security_group.SG-Automation.id]
  associate_public_ip_address = true
  
  tags = {
    Name = "Terra-IAC"
  }
}


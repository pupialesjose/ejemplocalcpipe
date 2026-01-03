# main.tf
provider "aws" {
  region = var.aws_region
}

##########################
# 1️⃣ VPC
##########################
resource "aws_vpc" "calculadora_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "calculadora-vpc"
  }
}

##########################
# 2️⃣ Subnet pública
##########################
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.calculadora_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "calculadora-subnet"
  }
}

##########################
# 3️⃣ Internet Gateway
##########################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.calculadora_vpc.id
  tags = {
    Name = "calculadora-igw"
  }
}

##########################
# 4️⃣ Route Table
##########################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.calculadora_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "calculadora-public-rt"
  }
}

# Asociar Route Table a la Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

##########################
# 5️⃣ Security Group
##########################
resource "aws_security_group" "app_sg" {
  name   = "calculadora-sg"
  vpc_id = aws_vpc.calculadora_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "calculadora-sg"
  }
}

##########################
# 6️⃣ EC2 Instance
##########################
resource "aws_instance" "calculadora" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    apt update
    apt install -y docker.io
    systemctl enable docker
    systemctl start docker

    docker run -d \
      --name calculadora \
      -p 8080:8080 \
      ${var.docker_image}
  EOF

  tags = {
    Name = "calculadora-instance"
  }
}

##########################
# 7️⃣ Output
##########################
output "instance_public_ip" {
  value = aws_instance.calculadora.public_ip
}

output "instance_public_dns" {
  value = aws_instance.calculadora.public_dns
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "app_sg" {
  name = "calculadora-sg"

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
}

resource "aws_instance" "calculadora" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

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
}

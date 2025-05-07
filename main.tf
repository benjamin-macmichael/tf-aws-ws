terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "webserver" {
  ami           = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
  instance_type = "t2.micro"
  user_data     = <<EOF
            #!/bin/bash
            sudo apt-get update
            sudo apt-get install -y python3
            sudo mkdir -p /var/www/html
            echo "Hell0, W0rld!" > /var/www/html/index.html
            python3 -m http.server 8080 --directory /var/www/html &
            EOF

  tags = {
    Name = "webserver"
  }

  security_groups = [aws_security_group.webserver_sg.name]
}

resource "aws_security_group" "webserver_sg" {
  name        = "webserver_sg"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 8080
    to_port     = 8080
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

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
  availability_zone = "us-east-1a"
}
provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}


resource "aws_instance" "my_server" {
  ami           = "ami-0a6b2839d44d781b2"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.security_group.id ]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
}

resource "aws_security_group" "security_group" {
  name        = "my-sg"
  description = "Allow HTTP traffic"
  vpc_id = data.aws_vpc.default.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

}



# -------------------------
# Define aws provider
# -------------------------
provider "aws" {
  region = "us-east-1"
}

# ----------------------------------------------------
# Data Source to get the default VPC ID 
# ----------------------------------------------------
data "aws_vpc" "default" {
  default = true
}


# ---------------------------------------
# Define AMI instance: Ububtu  -> https://cloud-images.ubuntu.com/locator/ec2/
# ---------------------------------------
resource "aws_instance" "my_server" {
  ami           = "ami-0a6b2839d44d781b2"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.security_group.id ]
  
  // Crete a file with the user data
  // used to install the web server and start it
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
}


# ---------------------------------------
# Define Security Group
# ---------------------------------------
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
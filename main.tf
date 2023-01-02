
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

# ----------------------------------------------------
# Data Source to get the default subnet ID
# ----------------------------------------------------
data "aws_subnet" "az_a" {
  availability_zone = "us-east-1a"
  #if you have more than one subnet in the same AZ, you can use the default_for_az attribute to get the default subnet for the AZ
  default_for_az              =  true
}
data "aws_subnet" "az_b" {
  availability_zone = "us-east-1b"
  #if you have more than one subnet in the same AZ, you can use the default_for_az attribute to get the default subnet for the AZ
  default_for_az              =  true
}

# ---------------------------------------
# Define AMI instance: Ububtu  -> https://cloud-images.ubuntu.com/locator/ec2/
# server-1: web server
# ---------------------------------------
resource "aws_instance" "server-1" {
  ami           = "ami-0a6b2839d44d781b2"
  instance_type = "t2.micro"
  subnet_id = data.aws_subnet.az_a.id
  vpc_security_group_ids = [ aws_security_group.security_group.id ]
  
  // Crete a file with the user data
  // used to install the web server and start it
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World- server 1" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
    tags = {
    Name = "server-1"
  }
}


# ---------------------------------------
# Define server-2: web server
# ---------------------------------------
resource "aws_instance" "server-2" {
  ami           = "ami-0a6b2839d44d781b2"
  instance_type = "t2.micro"
  subnet_id = data.aws_subnet.az_b.id
  vpc_security_group_ids = [ aws_security_group.security_group.id ]
  
  // Crete a file with the user data
  // used to install the web server and start it
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World - server 2" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
    tags = {
    Name = "server-2"
  }
}

# ---------------------------------------
# Define Security Group
# ---------------------------------------
resource "aws_security_group" "security_group" {
  name        = "my-sg"
  description = "Allow HTTP traffic"
  vpc_id = data.aws_vpc.default.id
  ingress {
    security_groups = [aws_security_group.alb.id]
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

}

# ---------------------------------------
# Define Load Balancer
# ---------------------------------------
resource "aws_lb" "alb" {
  load_balancer_type  = "application"
  name                = "terraformers-alb"
  security_groups     = [aws_security_group.alb.id]
  subnets             = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
}


# ---------------------------------------
# Define Security Group for Load Balancer
# ---------------------------------------
resource "aws_security_group" "alb" {
  name          = "alb-sg"
  description   = "Allow  port 80  HTTPtraffic"
  vpc_id        = data.aws_vpc.default.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

}


# ---------------------------------------
# Define Target Group of Load Balancer
# ---------------------------------------
resource "aws_lb_target_group" "this" {
  name                  = "alb-tg"
  port                  = 80
  protocol              = "HTTP"
  vpc_id                = data.aws_vpc.default.id

  health_check {
    enabled             = true
    matcher             = "200"
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
  }

}

# ---------------------------------------
# Define Listener of Load Balancer server 1
# ---------------------------------------
resource "aws_lb_target_group_attachment" "server-1" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.server-1.id
  port             = 8080
}


# ---------------------------------------
# Define Listener of Load Balancer server 2
# ---------------------------------------
resource "aws_lb_target_group_attachment" "server-2" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.server-2.id
  port             = 8080
}

# ---------------------------------------
# Define Listener of Load Balancer
# ---------------------------------------
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
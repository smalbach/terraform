
# -------------------------
# Define aws provider
# -------------------------
provider "aws" {
  region = local.region
}

locals {
  # Define the security group name
  region = "us-east-1"
  ami = var.ubuntu_ami[local.region]
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
data "aws_subnet" "public_subnet" {
  for_each = var.servers
  availability_zone = "${local.region}${each.value.az}"
  #if you have more than one subnet in the same AZ, you can use the default_for_az attribute to get the default subnet for the AZ
  default_for_az              =  true
}
 

# ---------------------------------------
# Define AMI instance: Ububtu  -> https://cloud-images.ubuntu.com/locator/ec2/
# server-1: web server
# ---------------------------------------
resource "aws_instance" "server" {
  for_each = var.servers
  ami           = local.ami
  instance_type = var.instance_type
  subnet_id = data.aws_subnet.public_subnet[each.key].id //each.key is server-1 or server-2
  vpc_security_group_ids = [ aws_security_group.security_group.id ]
  // Crete a file with the user data
  // used to install the web server and start it
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World - I'm ${each.value.name}" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
    tags = {
    Name = "server-1"
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
    from_port   = var.server_port
    to_port     = var.server_port
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
  #subnets             = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
  subnets             = [for subnet in data.aws_subnet.public_subnet : subnet.id]
}


# ---------------------------------------
# Define Security Group for Load Balancer
# ---------------------------------------
resource "aws_security_group" "alb" {
  name          = "alb-sg"
  description   = "Allow  port ${var.lb_port}  HTTPtraffic"
  vpc_id        = data.aws_vpc.default.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
    from_port   = var.lb_port
    to_port     = var.lb_port
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
  }

}


# ---------------------------------------
# Define Target Group of Load Balancer
# ---------------------------------------
resource "aws_lb_target_group" "this" {
  name                  = "alb-tg"
  port                  = var.lb_port
  protocol              = "HTTP"
  vpc_id                = data.aws_vpc.default.id

  health_check {
    enabled             = true
    matcher             = "200"
    path                = "/"
    port                = "${var.server_port}"
    protocol            = "HTTP"
  }

}

# ---------------------------------------
# Define Listener of Load Balancer server map
# ---------------------------------------

resource "aws_lb_target_group_attachment" "server" {
  for_each = var.servers
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.server[each.key].id
  port             = var.server_port
}


# ---------------------------------------
# Define Listener of Load Balancer server 1
# ---------------------------------------
# resource "aws_lb_target_group_attachment" "server-1" {
#   target_group_arn = aws_lb_target_group.this.arn
#   target_id        = aws_instance.server-1.id
#   port             = var.server_port
# }


# # ---------------------------------------
# # Define Listener of Load Balancer server 2
# # ---------------------------------------
# resource "aws_lb_target_group_attachment" "server-2" {
#   target_group_arn = aws_lb_target_group.this.arn
#   target_id        = aws_instance.server-2.id
#   port             = var.server_port
# }

# ---------------------------------------
# Define Listener of Load Balancer
# ---------------------------------------
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.lb_port
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
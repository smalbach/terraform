
# ---------------------------------------
# Define AMI instance: Ubuntu  -> https://cloud-images.ubuntu.com/locator/ec2/
# ---------------------------------------
resource "aws_instance" "server" {
  for_each                = var.servers

  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = each.value.subnet_id
  vpc_security_group_ids  = [ aws_security_group.security_group.id ]
  // Crete a file with the user data
  // used to install the web server and start it
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World - I'm ${each.value.name}" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  tags = {
    Name = each.value.name
  }
}


# ---------------------------------------
# Define Security Group
# ---------------------------------------
resource "aws_security_group" "security_group" {
  name        = "my-sg"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "TCP"
  }
}

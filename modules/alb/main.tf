
# ---------------------------------------
# Define Load Balancer
# ---------------------------------------
resource "aws_lb" "alb" {
  load_balancer_type  = "application"
  name                = "terraformers-alb-${var.environment}"
  security_groups     = [aws_security_group.alb.id]
  subnets             =  var.subnet_ids
}


# ---------------------------------------
# Define Security Group for Load Balancer
# ---------------------------------------
resource "aws_security_group" "alb" {
  name          = "alb-sg-${var.environment}"
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

# ----------------------------------------------------
# Data Source para obtener el ID de la VPC por defecto
# ----------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

# ---------------------------------------
# Define Target Group of Load Balancer
# ---------------------------------------
resource "aws_lb_target_group" "this" {
  name                  = "alb-tg-${var.environment}"
  port                  = var.lb_port
  protocol              = "HTTP"
  vpc_id                = data.aws_vpc.default.id

  health_check {
    enabled             = true
    matcher             = "200"
    path                = "/"
    port                = var.server_port
    protocol            = "HTTP"
  }

}

# ---------------------------------------
# Define Listener of Load Balancer server map
# ---------------------------------------
resource "aws_lb_target_group_attachment" "server" {
  count = length(var.instances_ids)

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = element(var.instances_ids, count.index)
  port             = var.server_port
}

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
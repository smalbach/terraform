#---------------------------------------
# get the public dns of the instance load balancer
#---------------------------------------
output "public_dns_load_balancer" {
  description = "value of the public dns load balancer"
  value = "http://${aws_lb.alb.dns_name}:${var.lb_port}"
}

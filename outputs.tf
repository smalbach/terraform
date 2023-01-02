#---------------------------------------
# get the public dns of the instance server 1
#---------------------------------------
output "public_dns_server_1" {
  description = "value of the public dns"
  value = "http://${aws_instance.server-1.public_dns}:8080"
}

#---------------------------------------
# get the public ipv4 of the instance server 1
#---------------------------------------
output "public_ip_server_1" {
  description = "value of the public ip"
  value = "http://${aws_instance.server-1.public_ip}:8080"
}



#---------------------------------------
# get the public dns of the instance server 2
#---------------------------------------
output "public_dns_server_2" {
  description = "value of the public dns"
  value = "http://${aws_instance.server-2.public_dns}:8080"
}

#---------------------------------------
# get the public ipv4 of the instance server 2
#---------------------------------------
output "public_ip_server_2" {
  description = "value of the public ip"
  value = "http://${aws_instance.server-2.public_ip}:8080"
}



#---------------------------------------
# get the public dns of the instance load balancer
#---------------------------------------
output "public_dns_load_balancer" {
  description = "value of the public dns load balancer"
  value = "http://${aws_lb.alb.dns_name}"
}

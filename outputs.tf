#---------------------------------------
# get the public dns of the instance
#---------------------------------------
output "public_dns" {
  description = "value of the public dns"
  value = "http://${aws_instance.my_server.public_dns}:8080"
}

#---------------------------------------
# get the public ipv4 of the instance
#---------------------------------------
output "public_ip" {
  description = "value of the public ip"
  value = "http://${aws_instance.my_server.public_ip}:8080"
}

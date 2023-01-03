output "instances_ids" {
  description = "List of instance ids"
  value       = [for server in aws_instance.server :  server.id ]
}
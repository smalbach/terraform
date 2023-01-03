output "instances_ids" {
  description = "IDs of the instances"
  value       = module.loadbalancer.public_dns_load_balancer
}

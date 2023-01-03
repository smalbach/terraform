variable "subnet_ids" {
  description = "List of subnet ids"
  type        = set(string)
}

variable "instances_ids" {
  description = "Id of instances"
  type        = list(string)
}
variable "lb_port" {
  description = "Port to use for the server LB"
  type        = number
  default     = 80
  validation {
    condition     = var.lb_port > 0 && var.lb_port < 65536
    error_message = "The server_port must be between 1 and 65536."
  }
}

variable "server_port" {
  description = "Port to use for the server EC2"
  type        = number
  default     = 8080

  validation {
    condition     = var.server_port > 0 && var.server_port < 65536
    error_message = "The server_port must be between 1 and 65536."
  }
}



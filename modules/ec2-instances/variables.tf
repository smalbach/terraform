variable "server_port" {
  description = "Port to use for the server EC2"
  type        = number
  default     = 8080

  validation {
    condition     = var.server_port > 0 && var.server_port < 65536
    error_message = "The server_port must be between 1 and 65536."
  }
}


variable "instance_type" {
  description = "Type of instance to use for the server"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description     = "AMI to use for the server by region"
  type            = string
}

variable "servers" {
  description   = "Map of servers to create with their name and  subnet_id"
  type          = map(object({
    name        = string
    subnet_id   = string
  }))
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = ""
}
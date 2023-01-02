variable "server_port" {
  description = "Port to use for the server EC2"
  type        = number
  default     = 8080

  validation {
    condition     = var.server_port > 0 && var.server_port < 65536
    error_message = "The server_port must be between 1 and 65536."
  }
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

variable "instance_type" {
  description = "Type of instance to use for the server"
  type        = string
  default     = "t2.micro"
}

variable "ubuntu_ami" {
  description = "AMI to use for the server by region"
  type        = map(string)
  default = {
    us-east-1 = "ami-0a6b2839d44d781b2"
    us-east-1-am = "ami-0b5eea76982371e91"
  }
}
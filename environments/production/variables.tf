variable "server_port" {
  description = "Port to use for the server EC2"
  type        = number
  default     = 8080

  validation {
    condition     = var.server_port > 0 && var.server_port < 65536
    error_message = "The server_port must be between 1 and 65536."
  }
}

variable "ubuntu_ami" {
  description = "AMI por region"
  type        = map(string)

  // Ubuntu  -> https://cloud-images.ubuntu.com/locator/ec2/
  default = {
    us-east-1 = "ami-0574da719dca65348" # Ubuntu
    us-east-2 = "ami-0574da719dca65348" # Ubuntu
  }
}

variable "servers" {
  description = "Map of servers to create with their name and availability zone"

   type = map(object({
    name = string,
    az     = string
    })
  )

  default = {
    "server-1" = { name = "server-1", az = "a" },
    "server-2" = { name = "server-2", az = "b" },
  }
}

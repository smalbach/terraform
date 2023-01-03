
# -------------------------
# Define aws provider
# -------------------------
provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  ami = var.ubuntu_ami[local.region]
  lb_port = 80
  server_port = 8080
  environment = "prod"
}

# ----------------------------------------------------
# Data Source to get the default subnet ID
# ----------------------------------------------------
data "aws_subnet" "public_subnet" {
  for_each = var.servers
  availability_zone = "${local.region}${each.value.az}"
  #if you have more than one subnet in the same AZ, you can use the default_for_az attribute to get the default subnet for the AZ
  default_for_az              =  true
}

module "ec2_servers" {
  source        = "../../modules/ec2-instances"
  instance_type = "t2.nano"
  ami_id        = var.ubuntu_ami[local.region]
  server_port   = local.server_port
  servers       = {
    for id_ser, data_val in var.servers :
    id_ser => {
      name = data_val.name
      subnet_id = data.aws_subnet.public_subnet[id_ser].id
    }
  }
  environment   = local.environment
}

module "loadbalancer" {
  source        = "../../modules/alb"

  subnet_ids    = [for subnet in data.aws_subnet.public_subnet : subnet.id]
  instances_ids = module.ec2_servers.instances_ids
  lb_port       = local.lb_port
  server_port   = local.server_port
  environment   = local.environment
}

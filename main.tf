data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

locals {

  module_name  = "Terraform - ${basename(path.cwd)}"
  project_name = upper(split("-", var.name)[0])

  azs             = slice(data.aws_availability_zones.available.names, 0, var.azs_count)
  private_subnets = length(var.private_subnets) > 0 ? var.private_subnets : []
  public_subnets  = length(var.public_subnets) > 0 ? var.public_subnets : []

}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name    = var.name
  cidr    = var.primary_cidr
  version = "3.0.0"

  # it will use first 2 az in that region
  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Automation  = local.module_name
    Project     = local.project_name
    Terraform   = "true"
    Environment = var.stage
  }

}

module "bastion_host_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.2.0"

  name                = "${var.name}-bastion-sg"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = {
    Automation  = local.module_name
    Project     = local.project_name
    Terraform   = "true"
    Environment = var.stage
  }
}

module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = "bastion"
  instance_count = 1

  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = var.instance_type
  key_name               = var.key_pair
  monitoring             = false
  vpc_security_group_ids = [module.bastion_host_sg.security_group_id]
  subnet_ids = flatten([
    module.vpc.public_subnets
  ])

  tags = {
    Automation  = local.module_name
    Project     = local.project_name
    Terraform   = "true"
    Environment = var.stage
  }

}

module "nginx_host_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.2.0"

  name   = "${var.name}-bastion-sg"
  vpc_id = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.bastion_host_sg.security_group_id
    },
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.bastion_host_sg.security_group_id
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = {
    Automation  = local.module_name
    Project     = local.project_name
    Terraform   = "true"
    Environment = var.stage
  }
}


module "ec2_nginx" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = "nginx"
  instance_count = 2

  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = var.instance_type
  key_name               = var.key_pair
  monitoring             = false
  vpc_security_group_ids = [module.nginx_host_sg.security_group_id]
  subnet_ids = flatten([
    module.vpc.private_subnets
  ])

  user_data_base64 = base64encode(file("${path.module}/scripts/nginx_userdata.sh"))

  tags = {
    Automation  = local.module_name
    Project     = local.project_name
    Terraform   = "true"
    Environment = var.stage
  }

}

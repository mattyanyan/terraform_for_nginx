locals {
  default_tag = { Terraform = "true", Product = "WeLendNGINX", Creator = "MatthewLam" }
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_configs.name
  cidr = var.vpc_configs.cidr

  azs                     = var.vpc_configs.azs
  enable_dns_hostnames    = var.vpc_configs.enable_dns_hostnames
  igw_tags                = merge(var.vpc_configs.tags, local.default_tag)
  map_public_ip_on_launch = var.vpc_configs.map_public_ip_on_launch
  public_subnet_suffix    = var.vpc_configs.public_subnet_suffix
  public_subnet_tags      = var.vpc_configs.public_subnet_tags
  public_subnets          = var.vpc_configs.public_subnets
  private_subnet_suffix   = var.vpc_configs.private_subnet_suffix
  private_subnet_tags     = var.vpc_configs.private_subnet_tags
  private_subnets         = var.vpc_configs.private_subnets
  tags                    = merge(var.vpc_configs.tags, local.default_tag)
}

# EC2 instance

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["910595266909"]
}


module "nginx_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.nginx_instance_configs.name

  ami                         = data.aws_ami.amazon_linux_2.id
  associate_public_ip_address = var.nginx_instance_configs.associate_public_ip_address
  instance_type               = var.nginx_instance_configs.instance_type
  key_name                    = var.nginx_instance_configs.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  tags                        = merge(var.nginx_instance_configs.tags, local.default_tag)
  user_data                   = var.nginx_instance_configs.user_data
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
}

resource "aws_security_group" "nginx_sg" {
  name        = var.nginx_sg_configs.name
  description = var.nginx_sg_configs.description
  vpc_id      = module.vpc.vpc_id
  tags        = merge(var.nginx_sg_configs.tags, local.default_tag)

  dynamic "ingress" {
    for_each = concat(var.nginx_sg_configs.ingress)
    content {
      from_port        = ingress.value["from_port"]
      to_port          = ingress.value["to_port"]
      cidr_blocks      = contains(keys(ingress.value), "cidr_blocks") ? ingress.value["cidr_blocks"] : []
      ipv6_cidr_blocks = contains(keys(ingress.value), "ipv6_cidr_blocks") ? ingress.value["ipv6_cidr_blocks"] : []
      description      = ingress.value["description"]
      protocol         = ingress.value["protocol"]
    }
  }

  dynamic "egress" {
    for_each = concat(var.nginx_sg_configs.egress)
    content {
      from_port        = egress.value["from_port"]
      to_port          = egress.value["to_port"]
      cidr_blocks      = contains(keys(egress.value), "cidr_blocks") ? egress.value["cidr_blocks"] : []
      ipv6_cidr_blocks = contains(keys(egress.value), "ipv6_cidr_blocks") ? egress.value["ipv6_cidr_blocks"] : []
      description      = egress.value["description"]
      protocol         = egress.value["protocol"]
    }
  }
}

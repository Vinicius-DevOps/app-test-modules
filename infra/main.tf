# VPC
module "vpc" {
  source               = "git::https://github.com/Vinicius-DevOps/terraform-aws-modules.git//modules/vpc?ref=main"
  vpc_cidr_block       = var.vpc_cidr_block
  environment          = var.environment
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# SG
module "sg" {
  source      = "git::https://github.com/Vinicius-DevOps/terraform-aws-modules.git//modules/sg?ref=main"
  environment = var.environment
  port_number = var.port_number
  vpc_id      = module.vpc.vpc_id
}

# ASG
module "asg" {
  source             = "git::https://github.com/Vinicius-DevOps/terraform-aws-modules.git//modules/asg?ref=main"
  environment        = var.environment
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  security_group_id  = module.sg.security_group_id
  key_name           = var.key_name
  user_data          = var.user_data
  private_subnet_ids = module.vpc.private_subnet_ids
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity
  target_group_arn   = module.alb.target_group_arn
}

# ALB
module "alb" {
  source                = "git::https://github.com/Vinicius-DevOps/terraform-aws-modules.git//modules/alb?ref=main"
  environment           = var.environment
  security_group_id     = module.sg.security_group_id
  subnet_public_id      = module.vpc.public_subnet_ids
  target_group_port     = var.target_group_port
  target_group_protocol = var.target_group_protocol
  vpc_id                = module.vpc.vpc_id
  health_check_path     = var.health_check_path
  health_check_port     = var.health_check_port
  listener_port         = var.listener_port
  listener_protocol     = var.listener_protocol
}
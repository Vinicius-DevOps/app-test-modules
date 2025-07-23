# Backend remotor S3
terraform {
  backend "s3" {
    bucket = var.bucket_name
    key    = "envs/staging/terraform.tfstate"
    region = var.aws_region
  }
}

module "vpc" {
  source = "git::https://github.com/Vinicius-DevOps/terraform-modules.git//modules/vpc?ref=main"

  environment          = var.environment
  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_cidrs  = [var.public_subnet_cidrs[0], var.public_subnet_cidrs[1]]
  private_subnet_cidrs = [var.private_subnet_cidrs[0], var.private_subnet_cidrs[1]]
}

module "sg" {
  source = "git::https://github.com/Vinicius-DevOps/terraform-modules.git//modules/security-group?ref=main"
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source              = "git::https://github.com/Vinicius-DevOps/terraform-modules.git//modules/alb?ref=main"
  vpc_id              = module.vpc.vpc_id
  security_groups_ids = [module.sg.security_group_id]
  subnets_ids         = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]

}

module "asg" {
  source                 = "git::https://github.com/Vinicius-DevOps/terraform-modules.git//modules/autoscaling-group?ref=main"
  name                   = var.environment
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_ids             = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  target_group_arns      = [module.alb.target_group_arn]
  environment            = var.environment
}

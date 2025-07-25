vpc_cidr_block       = "10.0.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.101.0/24", "10.1.102.0/24"]
name                 = "app-test"
instance_type        = "t2.micro"
tags = {
  "Environment" = "staging"
}
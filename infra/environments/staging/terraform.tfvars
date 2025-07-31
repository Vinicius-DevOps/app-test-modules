# VPC
vpc_cidr_block       = "10.0.0.0/16"
environment          = "staging"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

# Lauch Template
instance_type = "t2.micro"
key_name      = "key-par"

# Auto Scaling Group
min_size         = 1
max_size         = 3
desired_capacity = 1
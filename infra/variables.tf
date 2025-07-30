# AWS Region
variable "aws_region" {
  description = "AWS region."
  type        = string
}

# VPC
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}
variable "environment" {
  description = "Environment name."
  type        = string
}
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
}
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
}

# Port number for Ingress Rules
variable "port_number" {
  description = "Port number for the ingress rule."
  type        = list(number)
  default     = [80, 443, 5000, 22]
}

# Launch Template
variable "ami_id" {
  description = "AMI ID for the launch template."
  type        = string
}
variable "instance_type" {
  description = "Instance type for the launch template."
  type        = string
}
variable "key_name" {
  description = "Key name for the launch template."
  type        = string
}
variable "user_data" {
  description = "User data script to initialize the instance"
  type        = string
  default     = <<EOF
  #!/bin/bash
  cd /opt/app || exit 1
  docker compose up -d
  EOF
}


# Auto Scaling Group
variable "min_size" {
  description = "Minimum size of the Auto Scaling Group."
  type        = number
}
variable "max_size" {
  description = "Maximum size of the Auto Scaling Group."
  type        = number
}
variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group."
  type        = number
}
variable "tags" {
  description = "Tags for the Auto Scaling Group."
  type        = map(string)
  default     = {}
}

# Target Group
variable "target_group_port" {
  description = "Port for the target group."
  type        = number
  default     = 80
}
variable "target_group_protocol" {
  description = "Protocol for the target group."
  type        = string
  default     = "HTTP"
}

# Health Check
variable "health_check_path" {
  description = "Path for the health check."
  type        = string
  default     = "/"
}
variable "health_check_port" {
  description = "Port for the health check."
  type        = string
  default     = "80"
}

# Listener
variable "listener_port" {
  description = "Port for the listener."
  type        = number
  default     = 80
}
variable "listener_protocol" {
  description = "Protocol for the listener."
  type        = string
  default     = "HTTP"
}
variable "aws_region" {
  description = "AWS region where the resources will be deployed."
  type        = string
}
variable "environment" {
  description = "Environment name."
  type        = string
}
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
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
variable "ami_id" {
  description = "AMI ID for the EC2 instances."
  type        = string
}
variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}
variable "name" {
  description = "Name for the resources."
  type        = string
}
variable "tags" {
  description = "Tags for the resources."
  type        = map(string)
}
variable "bucket_name" {
  description = "Name for the S3 bucket."
  type        = string
}
variable "dynamodb_name" {
  description = "Name for the DynamoDB table."
  type        = string
}
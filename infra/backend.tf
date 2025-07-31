terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "placeholder"
    key    = "placeholder"
    region = "placeholder"
    encrypt = true
    use_lockfile = true
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.4.0"
    }
  }
}
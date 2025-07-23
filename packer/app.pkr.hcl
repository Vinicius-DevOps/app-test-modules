packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "environment" {
  type    = string
}


source "amazon-ebs" "docker_app" {
  region                  = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type           = "t3.micro"
  ssh_username            = "ubuntu"
  ami_name                = "docker-app-${var.environment}-{{timestamp}}"
}

build {
  name    = "Build Docker AMI"
  sources = ["source.amazon-ebs.docker_app"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io docker-compose",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu"
    ]
  }

  provisioner "file" {
    source      = "../app"
    destination = "/opt/app"
  }

  provisioner "shell" {
    inline = [
      "cd /opt/app",
      "sudo docker-compose build",
      "sudo docker-compose up -d"
    ]
  }
}

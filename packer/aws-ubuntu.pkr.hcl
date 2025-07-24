packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "ami_name" {
  type    = string
  default = "learn-packer-linux-aws-redis-msg-vinny"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = var.ami_name
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = var.ami_name
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install ca-certificates curl -y",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo groupadd docker || true",
      "sudo usermod -aG docker ubuntu"
    ]
  }

  provisioner "shell" {
  inline = [
    "sudo mkdir -p /opt/app",
    "sudo chown -R ubuntu:ubuntu /opt/app"
    ]
  }

  provisioner "file" {
    source      = "./app/"
    destination = "/opt/app/"
  }

  provisioner "shell" {
  inline = [
    "cd /opt/app",
    "ls -la",
    "sudo docker compose version",
    "sudo docker compose up -d --build"
    ]
  }
}
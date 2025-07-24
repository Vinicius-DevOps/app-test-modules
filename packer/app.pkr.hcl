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
  type = string
}

source "amazon-ebs" "docker_app" {
  region = var.aws_region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  instance_type = "t3.micro"
  ssh_username  = "ubuntu"
  ami_name      = "docker-app-${var.environment}-{{timestamp}}"
}

build {
  name    = "Build Docker AMI"
  sources = ["source.amazon-ebs.docker_app"]

  # Instalação do Docker e Compose (com workaround do APT bug)
  provisioner "shell" {
    inline = [
      "sudo rm -f /etc/apt/apt.conf.d/50command-not-found",
      "sudo apt-get update",
      "sudo apt-get install -y ca-certificates curl gnupg lsb-release",

      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",

      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",

      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu"
    ]
  }

  # Copia a aplicação para a AMI
  provisioner "file" {
    source      = "${path.root}/../app"
    destination = "/tmp/app"
  }

  # Move app e sobe containers
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/app",
      "sudo mv /tmp/app/* /opt/app/",
      "cd /opt/app",
      "sudo docker compose build",
      "sudo docker compose up -d"
    ]
  }
}

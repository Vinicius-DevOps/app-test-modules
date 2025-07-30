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
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "ami_name" {
  type    = string
  default = "learn-packer-linux-aws-redis-msg"
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
  name    = var.ami_name
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
      "sudo docker compose -f /opt/app/docker-compose.yml up -d --build"
    ]
  }

  provisioner "file" {
    content     = <<EOF
[Unit]
Description=Start Docker Compose App
After=network.target docker.service
Requires=docker.service

[Service]
Type=exec
Restart=always
WorkingDirectory=/opt/app
ExecStart=/usr/bin/env docker compose up -d
ExecStop=/usr/bin/env docker compose down
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF
    destination = "/tmp/myapp.service"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/myapp.service /etc/systemd/system/myapp.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable myapp.service"
    ]
  }
}
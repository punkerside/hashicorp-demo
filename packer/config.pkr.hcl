packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "name" {
  type = string
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "main" {
  ami_name      = "${var.name}-${local.timestamp}"
  instance_type = "t3a.small"

  subnet_filter {
    filters = {
          "tag:Name": "${var.name}-public-*"
    }
    most_free = true
    random    = false
  }

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.main"]

  provisioner "ansible" {
    playbook_file = "ansible/playbook.yml"
  }
}
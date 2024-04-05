packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

locals {
  timestamp = formatdate("YYYY-MM-DD", timestamp())
}

locals {
  creds = jsondecode(file("creds.json"))
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "northflier-${local.timestamp}"
  instance_type = "t2.small"
  region        = "us-west-2"

  access_key = local.creds.AccessKeyId
  secret_key = local.creds.SecretAccessKey

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-*-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
  vpc_id       = var.vpc_id
  subnet_id    = var.subnet_id

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  run_tags = {
    Name = "northflier-packer-build"
  }

  tags = {
    Name = "northflier-${local.timestamp}"
  }
}

build {
  name = "northflier"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    script = "install_northflier.sh"
  }

  post-processor "manifest" {
    output     = "northflier.json"
    strip_path = true
  }

  post-processor "shell-local" {
    inline = [
      "echo 'AMI Name: northflier-${local.timestamp}'"
    ]
  }
}

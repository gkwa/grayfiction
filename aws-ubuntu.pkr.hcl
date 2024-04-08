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

variable "ami_name_prefix" {
  type = string
}

variable "source_ami_filter_name" {
  type = string
}

locals {
  timestamp = formatdate("YYYY-MM-DD", timestamp())
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name_prefix}-${local.timestamp}"
  instance_type = "t2.small"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = var.source_ami_filter_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  vpc_id       = var.vpc_id
  subnet_id    = var.subnet_id
  spot_price   = "auto"
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }
  run_tags = {
    Name = "${var.ami_name_prefix}-packer-build"
  }
  tags = {
    Name = "${var.ami_name_prefix}-${local.timestamp}"
  }
}

build {
  name = var.ami_name_prefix
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    script = "install_${var.ami_name_prefix}.sh"
  }
  post-processor "manifest" {
    output     = "${var.ami_name_prefix}.json"
    strip_path = true
  }
  post-processor "shell-local" {
    inline = [
      "echo 'AMI Name: ${var.ami_name_prefix}-${local.timestamp}'"
    ]
  }
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "vpc_id" {
  type    = string
  default = env("AWS_VPC_ID")
}

variable "subnet_id" {
  type    = string
  default = env("AWS_SUBNET_ID")
}

variable "region" {
  type    = string
  default = env("AWS_DEFAULT_REGION")
}

variable "ami_name_prefix" {
  type = string
}

variable "source_ami" {
  type = object({
    filter_name  = string
    owners       = list(string)
    ssh_username = string
  })
}

variable "instance_type" {
  type = string
}

variable "provision_script" {
  type = string
}

variable "spot_price" {
  type    = string
  default = ""
}

variable "force_deregister" {
  type    = bool
  default = false
}

variable "force_delete_snapshot" {
  type    = bool
  default = false
}

variable "volume_size" {
  type    = number
  default = 8
}

locals {
  timestamp = formatdate("YYYY-MM-DD-hhmmss", timestamp())
}

source "amazon-ebs" "ubuntu" {
  ami_name              = "${var.ami_name_prefix}-${local.timestamp}"
  force_delete_snapshot = var.force_delete_snapshot
  force_deregister      = var.force_deregister
  instance_type         = var.instance_type
  region                = var.region
  spot_price            = var.spot_price != "" ? var.spot_price : "auto"
  ssh_username          = var.source_ami.ssh_username
  subnet_id             = var.subnet_id
  vpc_id                = var.vpc_id

  aws_polling {
    delay_seconds = 120 // 2 minutes
    max_attempts  = 45  // 45 attempts * 2 minutes = 90 minutes (1.5 hours)
  }

  source_ami_filter {
    filters = {
      name                = var.source_ami.filter_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = var.source_ami.owners
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  run_tags = {
    Name    = "${var.ami_name_prefix}-packer-build"
    Creator = "packer"
  }
  run_volume_tags = {
    Creator = "packer"
  }
  snapshot_tags = {
    Creator = "packer"
  }
  tags = {
    Creator : "packer"
    Name = "${var.ami_name_prefix}-${local.timestamp}"
  }
}

build {
  name = var.ami_name_prefix
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline            = ["sudo reboot"]
    expect_disconnect = true
  }

  provisioner "shell" {
    inline = [
      "echo 'Prevent apt-get lock timeouts'",
      "echo 'DPkg::Lock::Timeout \"600\";' | sudo tee /etc/apt/apt.conf.d/99dpkg-lock-timeout",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Waiting for dns...'",
      "timeout 30s curl --retry 9999 --connect-timeout 1 -sSf https://www.google.com >/dev/null",
    ]
  }
  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    script = "${var.provision_script}"
  }

  provisioner "shell" {
    inline            = ["sudo reboot"]
    expect_disconnect = true
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

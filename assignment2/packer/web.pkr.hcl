packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_name_prefix" {
  type    = string
  default = "acs730-a2-golden-web"
}

source "amazon-ebs" "web" {
  region        = var.aws_region
  instance_type = var.instance_type
  ami_name      = "${var.ami_name_prefix}-{{timestamp}}"
  ssh_username  = "ec2-user"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-kernel-6.1-x86_64"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  tags = {
    Name    = "${var.ami_name_prefix}"
    Project = "acs730-assignment2"
  }
}

build {
  name    = "golden-web-ami"
  sources = ["source.amazon-ebs.web"]

  provisioner "ansible" {
    playbook_file = "../ansible/site.yml"
    roles_path    = "../ansible/roles"
    ansible_env_vars = [
     "PACKER_ANSIBLE_CONN=ssh"
    ]
    extra_arguments = [
      "--extra-vars",
      "ansible_connection=ssh ansible_python_interpreter=/usr/bin/python3 ansible_ssh_transfer_method=piped webserver_pkg_name=nginx webserver_service_name=nginx"
    ]
  }
}

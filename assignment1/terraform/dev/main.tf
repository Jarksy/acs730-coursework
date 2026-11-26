terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  backend "s3" {
    bucket = "acs730-tfstate-936666204674"
    key    = "assignment1/dev/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "app_stack" {
  source = "../modules/app_stack"

  env                = "dev"
  aws_region         = "us-east-1"
  vpc_cidr           = "10.10.0.0/16"
  instance_type      = "t3.micro"
  ssm_parameter_name = "/assignment1/app/db_password"

  subnets = {
    subnet_a = {
      cidr_block = "10.10.1.0/24"
      az_suffix  = "a"
    }
  }

  tags = {
    Tier = "development"
  }
}

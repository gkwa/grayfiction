terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "iam_user" {
  source = "./modules/iam_user"
  name   = "grayfiction"
}

module "iam_role" {
  source = "./modules/iam_role"
  name   = "grayfiction"
}

module "iam_group" {
  source    = "./modules/iam_group"
  name      = "grayfiction"
  user_name = module.iam_user.user_name
  role_name = module.iam_role.role_name
}

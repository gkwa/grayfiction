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
  source           = "./modules/iam_user"
  name             = "grayfiction"
  iam_boundary_arn = aws_iam_policy.permission_boundary.arn
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

resource "aws_iam_policy" "permission_boundary" {
  name        = "grayfiction-permission-boundary"
  path        = "/"
  description = "Permission boundary policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/Name": "grayfiction"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeRegions"
        ]
        Resource = "*"
      }
    ]
  })
}

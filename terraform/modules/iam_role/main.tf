resource "aws_iam_role" "role" {
  name = var.name
  tags = {
    Name = var.name
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_permissions" {
  name   = "${var.name}-ec2-permissions"
  role   = aws_iam_role.role.id
  policy = file("${path.module}/policies/ec2_permissions.json")
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  name   = "${var.name}-cloudwatch-logs"
  role   = aws_iam_role.role.id
  policy = file("${path.module}/policies/cloudwatch_logs.json")
}

resource "aws_iam_role_policy" "delete_images" {
  name = "${var.name}-delete-images"
  role = aws_iam_role.role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DeregisterImage",
          "ec2:DescribeImages"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "ec2:Name" = "northflier-???-??-??"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "describe_regions" {
  name = "${var.name}-describe-regions"
  role = aws_iam_role.role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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

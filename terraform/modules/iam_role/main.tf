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

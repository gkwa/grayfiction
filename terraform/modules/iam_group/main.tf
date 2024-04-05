resource "aws_iam_group" "group" {
  name = var.name
}

resource "aws_iam_group_membership" "group_membership" {
  name  = "${var.name}-membership"
  users = [var.user_name]
  group = aws_iam_group.group.name
}

resource "aws_iam_group_policy_attachment" "group_policy_attachment" {
  group      = aws_iam_group.group.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_group_policy" "assume_role_policy" {
  name  = "${var.name}-assume-role"
  group = aws_iam_group.group.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::*:role/${var.role_name}"
      }
    ]
  })
}

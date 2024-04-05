resource "aws_iam_user" "user" {
  name = var.name
  tags = {
    Name = var.name
  }
}

resource "aws_iam_user_policy_attachment" "user" {
  user       = aws_iam_user.user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}
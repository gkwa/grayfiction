
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
         AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
       }
     }
   ]
 })
}

resource "aws_iam_role_policy_attachment" "ec2_permissions" {
 policy_arn = aws_iam_policy.ec2_permissions.arn
 role       = aws_iam_role.role.name
}

resource "aws_iam_policy" "ec2_permissions" {
 name        = "${var.name}-ec2-permissions"
 path        = "/"
 description = "Permissions for EC2 instances"
 policy      = file("${path.module}/policies/ec2_permissions.json")
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
 policy_arn = aws_iam_policy.cloudwatch_logs.arn
 role       = aws_iam_role.role.name
}

resource "aws_iam_policy" "cloudwatch_logs" {
 name        = "${var.name}-cloudwatch-logs"
 path        = "/"
 description = "Permissions for CloudWatch Logs"
 policy      = file("${path.module}/policies/cloudwatch_logs.json")
}

data "aws_caller_identity" "current" {}

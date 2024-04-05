resource "aws_iam_group" "group" {
  name = var.name
}

resource "aws_iam_group_membership" "group_membership" {
  name  = "${var.name}-membership"
  users = [var.user_name]
  group = aws_iam_group.group.name
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

resource "aws_iam_policy" "custom_policy" {
  name        = "${var.name}-custom-policy"
  path        = "/"
  description = "Custom policy for ${var.name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "RatherSafeActions",
        Effect = "Allow",
        Action = [
          "ec2:CopyImage",
          "ec2:CreateImage",
          "ec2:CreateKeyPair",
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DescribeImages",
          "ec2:DescribeImageAttribute",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSnapshots",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "ec2:RegisterImage",
          "ec2:CreateSecurityGroup",
          "ec2:RunInstances"
        ],
        Resource = "*"
      },
      {
        Sid    = "DangerousActions",
        Effect = "Allow",
        Action = [
          "ec2:AttachVolume",
          "ec2:DeleteSnapshot",
          "ec2:DeleteVolume",
          "ec2:DeleteSecurityGroup",
          "ec2:DeregisterImage",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:DetachVolume",
          "ec2:ModifyImageAttribute",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifySnapshotAttribute",
          "ec2:StopInstances",
          "ec2:TerminateInstances"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/Name" = ["northflier-packer-build", "grayfiction"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "custom_policy_attachment" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.custom_policy.arn
}

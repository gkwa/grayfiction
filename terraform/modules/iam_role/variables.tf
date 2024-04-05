variable "name" {
 description = "The name of the IAM role"
 type        = string
}

-- terraform/modules/iam_user/main.tf --
resource "aws_iam_user" "user" {
 name = var.name
 tags = {
   Name = var.name
 }
}

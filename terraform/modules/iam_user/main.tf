
resource "aws_iam_user" "user" {
 name = var.name
 tags = {
   Name = var.name
 }
}

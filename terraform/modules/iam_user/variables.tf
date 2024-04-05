variable "name" {
  description = "The name of the IAM user"
  type        = string
}

variable "iam_boundary_arn" {
  description = "The ARN of the IAM permission boundary policy"
  type        = string
}

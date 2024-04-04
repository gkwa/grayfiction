variable "name" {
  description = "The name of the IAM group"
  type        = string
}

variable "user_name" {
  description = "The name of the IAM user to add to the group"
  type        = string
}

variable "role_name" {
  description = "The name of the IAM role to assume"
  type        = string
}

variable "repository_name" {
  type        = string
  description = "Repository Name"
}

variable "static_website_bucket_name" {
  type = string
}

variable "deployment_group_name" {
  type = string
}

variable "approval_email" {
  type = string
}

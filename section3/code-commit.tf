resource "aws_codecommit_repository" "repository" {
  repository_name = var.repository_name
  description     = "This is the Sample App Repository"
}

locals {
  codepipeline_variables = {
    # user = ""
    # token = ""
    ecr_repository_url = aws_ecr_repository.angular_app.repository_url
  }
}

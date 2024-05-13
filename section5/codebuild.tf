resource "aws_codebuild_project" "codebuild" {
  name          = "codebuild_${var.repository_name}"
  description   = "codebuild project for ${var.repository_name}"
  build_timeout = 5
  service_role  = aws_iam_role.codepipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
    }
  }

  source {
    buildspec = "buildspec-docker.yml"
    type      = "CODEPIPELINE"
  }

  source_version = "main"
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name = "/aws/codebuild/codebuild_${var.repository_name}"

  tags = {
    Environment = "dev"
    Application = var.repository_name
  }
}

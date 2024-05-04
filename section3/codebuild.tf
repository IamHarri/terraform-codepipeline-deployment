resource "aws_codebuild_project" "codebuild" {
  name          = "codebuild_${var.repository_name}"
  description   = "codebuild project for ${var.repository_name}"
  build_timeout = 5
  service_role  = aws_iam_role.codepipeline_role.arn # need it

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0" #"aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENV"
      value = "dev"
    }
  }

  logs_config {

  }

  source {
    buildspec       = "buildspec.yml"
    type            = "CODEPIPELINE"
    # location        = aws_codecommit_repository.repository.clone_url_http
    # git_clone_depth = 1
  }

  source_version = "main"
}


resource "aws_codebuild_project" "unit_test" {
  name          = "codebuild_${var.repository_name}_unit_test"
  description   = "codebuild project for ${var.repository_name}"
  build_timeout = 5
  service_role  = aws_iam_role.codepipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0" #"aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENV"
      value = "dev"
    }
  }

  logs_config {

  }

  source {
    buildspec       = "unit-test-buildspec.yml"
    type            = "CODEPIPELINE"
    # location        = aws_codecommit_repository.repository.clone_url_http
    # git_clone_depth = 1
  }

  source_version = "main"
}

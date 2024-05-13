resource "aws_codepipeline" "codepipeline" {
  name           = "codepipeline_deployment_${var.repository_name}"
  role_arn       = aws_iam_role.codepipeline_role.arn
  execution_mode = "SUPERSEDED"
  pipeline_type  = "V1"

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      input_artifacts  = []

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "IamHarri/shared-angular-app"
        BranchName       = "main"
        DetectChanges    = true
      }

    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      run_order        = 1

      configuration = {
        ProjectName  = "codebuild_${var.repository_name}" #name of code build project
        BatchEnabled = false
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.this.name
        ServiceName = "${aws_ecs_cluster.this.name}/${aws_ecs_service.angular_app.name}"
        FileName = "imagedefinitions.json"
        DeploymentTimeout = "10"
      }
    }
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "codepipeline-bucket-execution"
  force_destroy = true
}

data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}

resource "aws_codepipeline" "codepipeline" {
  name           = "myfirt_pipeline_deployment"
  role_arn       = aws_iam_role.codepipeline_role.arn
  execution_mode = "QUEUED"
  pipeline_type  = "V2"

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
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      input_artifacts  = []

      configuration = {
        RepositoryName       = var.repository_name
        BranchName           = "main"
        PollForSourceChanges = false #if set to true, pipeline will poll the repository for changes every default period, wast of resources
      }

    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        BucketName = module.s3-website-www.s3_bucket_id
        Extract    = true
        CannedACL  = "public-read"
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

# # resource "aws_codestarconnections_connection" "example" {
# #   name          = "example-connection"
# #   provider_type = "GitHub"
# # }


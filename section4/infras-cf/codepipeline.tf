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

    # action {
    #   name             = "Test"
    #   category         = "Test"
    #   owner            = "AWS"
    #   provider         = "CodeBuild"
    #   input_artifacts  = ["SourceArtifact"]
    #   output_artifacts = []
    #   version          = "1"
    #   run_order        = 1

    #   configuration = {
    #     ProjectName  = "codebuild_${var.repository_name}_unit_test" #name of code build project
    #     BatchEnabled = false
    #   }
    # }

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
    name = "Staging"

    action {
      name            = "CreatingStagingStack"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["SourceArtifact"]
      version         = "1"
      run_order       = 1

      configuration = {
        ActionMode   = "REPLACE_ON_FAILURE"
        StackName    = "StagingStack"
        TemplatePath = "SourceArtifact::cloudformation/staging-stack-template.yaml"
        Capabilities = "CAPABILITY_IAM"
        RoleArn      = aws_iam_role.cf_role.arn
        ParameterOverrides = jsonencode({
          WebServerImage    = data.aws_ami.amazon_linux.id
          WebServerRoleName = aws_iam_role.ec2_instance.name
        })
      }
      namespace = "StagingStackVariables"
    }

    action {
      name            = "DeployStaging"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 2

      configuration = {
        ApplicationName     = aws_codedeploy_app.angular_app.name
        DeploymentGroupName = "${var.deployment_group_name}-staging"
      }
    }

    action {
      name            = "ManualApproval"
      category        = "Approval"
      owner           = "AWS"
      provider        = "Manual"
      version         = "1"
      run_order       = 3

      configuration = {
        NotificationArn    = aws_sns_topic.codepipeline_approval.arn
        ExternalEntityLink = "http://#{StagingStackVariables.WebServerDnsName}"
        CustomData         = "Please review the pipeline execution"
      }
    }

    action {
      name            = "DeleteStagingStack"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["SourceArtifact"]
      version         = "1"
      run_order       = 4

      configuration = {
        ActionMode = "DELETE_ONLY"
        StackName  = "StagingStack"
        RoleArn    = aws_iam_role.cf_role.arn
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.angular_app.name
        DeploymentGroupName = var.deployment_group_name
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

# Listen for activity on the CodeCommit repo and trigger the CodePipeline
resource "aws_cloudwatch_event_rule" "codecommit_activity" {
  name_prefix = "codepipeline-trigger"
  description = "Detect commits to CodeCommit repo of ${var.repository_name} on main branch"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    resources   = [aws_codecommit_repository.repository.arn]
    detail = {
      event         = ["referenceCreated", "referenceUpdated"],
      referenceType = ["branch"],
      referenceName = ["main"]
    }
  })
}

resource "aws_cloudwatch_event_target" "cloudwatch_triggers_pipeline" {
  target_id = "${var.repository_name}-commits-trigger-pipeline"
  rule      = aws_cloudwatch_event_rule.codecommit_activity.name
  arn       = aws_codepipeline.codepipeline.arn
  role_arn  = aws_iam_role.cloudwatch_ci_role.arn
}

# Allows the CloudWatch event to assume roles
resource "aws_iam_role" "cloudwatch_ci_role" {
  name_prefix = "${var.repository_name}-cloudwatch-ci-"

  assume_role_policy = data.aws_iam_policy_document.cloudwatch_ci_assume_role.json

  inline_policy {
    name   = "cloudwatch_ci_iam_policy"
    policy = data.aws_iam_policy_document.cloudwatch_ci_iam_policy.json
  }
}

data "aws_iam_policy_document" "cloudwatch_ci_iam_policy" {
  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    # Allow CloudWatch to start the Pipeline
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    resources = [
      aws_codepipeline.codepipeline.arn
    ]
  }
}

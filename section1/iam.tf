# data "aws_iam_policy_document" "bucket_policy" {
#   statement {
#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }
#     actions = [
#       # "s3:ListBucket",
#       "s3:*Object*"
#     ]
#     resources = [
#       "${module.s3-website-www.s3_bucket_arn}/*"
#     ]
#   }
# }


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipeline_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "codepipeline_policy"
    policy = data.aws_iam_policy_document.codepipeline_policy.json
  }
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }

  # statement {
  #   effect    = "Allow"
  #   actions   = ["codestar-connections:UseConnection"]
  #   resources = [aws_codestarconnections_connection.example.arn]
  # }

  # statement {
  #   effect = "Allow"

  #   actions = [
  #     "codebuild:BatchGetBuilds",
  #     "codebuild:StartBuild",
  #   ]

  #   resources = ["*"]
  # }
}

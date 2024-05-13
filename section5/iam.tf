resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipeline_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "codepipeline_policy"
    policy = data.aws_iam_policy_document.codepipeline_policy.json
  }
}

resource "aws_iam_role" "ecs" {
  name               = "ecs_access_ecr_private_repository"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  inline_policy {
    name   = "ecs_access_ecr_private_repository"
    policy = data.aws_iam_policy_document.ecs.json
  }
}

resource "aws_iam_policy" "allow_ecs_instance" {
  name        = "allow-ecs-instance-connection"
  path        = "/"
  description = "allow-ecs-instance-connection"
  policy      = data.aws_iam_policy_document.ecs_instance.json
}
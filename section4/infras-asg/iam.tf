data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
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
      "s3:*",
      "codecommit:*",
      "codebuild:*",
      "codedeploy:*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "cloudwatch_ci_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# instance
data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "AmazonEC2RoleforAWSCodeDeploy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role" "codedeploy_role" {
  name               = "allow_instance_${var.repository_name}_to_deploy"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role.json
  inline_policy {
    name   = "allow_codedeploy_policy"
    policy = data.aws_iam_policy.AWSCodeDeployRole.policy
  }

  inline_policy {
    name   = "allow_codedeploy_bluegreen_deployment"
    policy = data.aws_iam_policy_document.codedeploy_bluegreen_deployment.json
  }
}

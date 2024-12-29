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
      "codedeploy:*",
      "cloudformation:*"
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
      "codestar-connections:UseConnection",
      "iam:PassRole"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = ["*"]
  }
}

# instance

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "AmazonEC2RoleforAWSCodeDeploy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    sid    = "AssumeFromEC2"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "ec2_instance" {
  name               = "allow_instance_${var.repository_name}_to_deploy"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
  inline_policy {
    name   = "allow_ssm_connection"
    policy = data.aws_iam_policy.AmazonSSMManagedInstanceCore.policy
  }

  inline_policy {
    name   = "allow_codedeploy"
    policy = data.aws_iam_policy.AmazonEC2RoleforAWSCodeDeploy.policy
  }
}


# codedeploy

data "aws_iam_policy" "AWSCodeDeployRole" {
  name = "AWSCodeDeployRole"
}

resource "aws_iam_role" "codedeploy_role" {
  name               = "allow_codedeploy_deploy_to_${var.repository_name}_instance"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role.json
  inline_policy {
    name   = "allow_codedeploy_policy"
    policy = data.aws_iam_policy.AWSCodeDeployRole.policy
  }
}

 
# cloudformation codepipeline
data "aws_iam_policy_document" "cf_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudformation.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cf_role" {
  name               = "allow_cloudformation_deployment_${var.repository_name}_infras"
  assume_role_policy = data.aws_iam_policy_document.cf_assume_role.json
  inline_policy {
    name   = "allow_cf_create_policy"
    policy = data.aws_iam_policy.IAMFullAccess.policy
  }
  inline_policy {
    name   = "allow_cf_create_instance"
    policy = data.aws_iam_policy.AmazonEC2FullAccess.policy
  }
}

data "aws_iam_policy" "IAMFullAccess" {
  arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

data "aws_iam_policy" "AmazonEC2FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
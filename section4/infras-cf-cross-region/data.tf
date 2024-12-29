data "aws_ami" "amazon_linux_us_east_2" {
  provider = aws.us-east-2
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-**-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-**-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_region" "current" {}

data "template_file" "user_data" {
  template = file("templates/user-data.sh")
  vars = {
    aws_region = data.aws_region.current.name
  }
}

data "aws_iam_policy_document" "codedeploy_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "codedeploy_bluegreen_deployment" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:RunInstances",
      "ec2:CreateTags",
      "iam:PassRole"
    ]

    resources = ["*"]
  }
}
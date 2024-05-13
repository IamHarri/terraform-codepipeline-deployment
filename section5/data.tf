data "aws_vpc" "vpc" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-kernel-5.10-hvm-**-ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


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

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "codecommit:*",
      "codebuild:*",
      "codedeploy:*",
      "ecs:*",
      "iam:PassRole"
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
    sid    = "allowPushImageToECR"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    sid    = "allowGetParameterStore"
    actions = [
      "ssm:GetParameters"
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

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "ecs.amazonaws.com"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ecs" {
  statement {
    effect = "Allow"
    sid = "ecsPullECRImage"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "ecs_instance" {
  statement {
    effect = "Allow"
    sid = "ecsInstance"
    actions = [
      "ecs:*"
      # "ecs:List*",
      # "ecs:DeleteCluster",
      # "ecs:DeregisterContainerInstance",
      # "ecs:ListContainerInstances",
      # "ecs:RegisterContainerInstance",
      # "ecs:SubmitContainerStateChange",
      # "ecs:SubmitTaskStateChange",
      # "ecs:DescribeContainerInstances",
      # "ecs:DescribeTasks",
      # "ecs:ListTasks",
      # "ecs:UpdateContainerAgent",
      # "ecs:StartTask",
      # "ecs:StopTask",
      # "ecs:RunTask",
      # "ecs:CreateCluster"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "template_file" "user_data" {
  template = file("templates/user-data.sh")
  vars = {
    cluster_name = "demo-cluster"
  }
}
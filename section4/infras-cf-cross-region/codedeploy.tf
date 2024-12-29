## us-east-1
resource "aws_codedeploy_app" "angular_app" {
  compute_platform = "Server"
  name             = var.repository_name
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Application = var.repository_name
  }
}

resource "aws_codedeploy_deployment_group" "angular_app_staging" {
  app_name               = aws_codedeploy_app.angular_app.name
  deployment_group_name  = "${var.deployment_group_name}-staging"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "Staging"
    }
  }

  auto_rollback_configuration {
    enabled = false
    events  = ["DEPLOYMENT_FAILURE"]
  }
  outdated_instances_strategy = "UPDATE"
}

### us-east-2
resource "aws_codedeploy_app" "angular_app_us_east_2" {
  provider         = aws.us-east-2
  compute_platform = "Server"
  name             = var.repository_name
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Application = var.repository_name
  }
}
resource "aws_codedeploy_deployment_group" "angular_app_staging_us_east_2" {
  provider               = aws.us-east-2
  app_name               = aws_codedeploy_app.angular_app_us_east_2.name
  deployment_group_name  = "${var.deployment_group_name}-staging"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "Staging"
    }
  }

  auto_rollback_configuration {
    enabled = false
    events  = ["DEPLOYMENT_FAILURE"]
  }
  outdated_instances_strategy = "UPDATE"
}

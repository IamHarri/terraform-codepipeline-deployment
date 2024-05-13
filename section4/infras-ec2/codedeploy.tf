resource "aws_codedeploy_app" "angular_app" {
  compute_platform = "Server"
  name             = var.repository_name
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Application = var.repository_name
  }
}

resource "aws_codedeploy_deployment_group" "angular_app" {
  app_name              = aws_codedeploy_app.angular_app.name
  deployment_group_name = var.deployment_group_name
  service_role_arn      = aws_iam_role.codedeploy_role.arn
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Application"
      type  = "KEY_AND_VALUE"
      value = var.repository_name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
  outdated_instances_strategy = "UPDATE"
}

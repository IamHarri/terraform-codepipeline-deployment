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
  app_name               = aws_codedeploy_app.angular_app.name
  deployment_group_name  = var.deployment_group_name
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce" #"CodeDeployDefault.OneAtATime"
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL" #"WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN" #"IN_PLACE"
  }
  autoscaling_groups = [module.asg.autoscaling_group_id]
  
  #Applied blue/green deployment
  load_balancer_info {
    target_group_info {
      name = module.alb.target_group_names[0]
    }
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

# staging deployment group

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

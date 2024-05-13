resource "aws_ecs_cluster" "this" {
  name = "demo-cluster"
}

resource "aws_ecs_capacity_provider" "this" {
  name = "demo-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.asg.autoscaling_group_arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      instance_warmup_period    = 300
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]
}

resource "aws_ecs_service" "angular_app" {
  name                = "angular-app"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.angular_app.arn
  desired_count       = 2
  launch_type         = "EC2"
  scheduling_strategy = "REPLICA"
  # iam_role            = aws_iam_service_linked_role.IAMServiceLinkedRole4.arn 

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:eu-west-3:329840729082:targetgroup/instance-AngularApp-http/f7b0ea88cbb2265d" #module.alb.lb_arn
    container_name   = "angular_app"
    container_port   = 80
  }
  network_configuration {
    subnets          = data.aws_subnets.subnets.ids
    security_groups  = [module.alb.security_group_id]
    assign_public_ip = false
  }
}
resource "aws_ecs_task_definition" "angular_app" {
  family                   = "${var.repository_name}-task-definition"
  requires_compatibilities = ["EC2"] #EC2
  network_mode             = "awsvpc"
  cpu                      = 256 # FARGATE is required
  memory                   = 512 # FARGATE
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn            = aws_iam_role.ecs.arn
  runtime_platform {
    cpu_architecture = "X86_64" # FARGATE
  }
  container_definitions = jsonencode([
    {
      name  = "angular_app"
      image = "${aws_ecr_repository.angular_app.repository_url}:latest"
      cpu       = 10
      memory    = 50
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      # logConfiguration = {
      #   logDriver = "awslogs"
      #   options = {
      #     awslogs-group         = aws_cloudwatch_log_group.log_group.name
      #     awslogs-region        = data.aws_region.current.name
      #     awslogs-stream-prefix = "ecs"
      #   }
      # }
    }
  ])
  # lifecycle {
  #   ignore_changes = [ container_definitions ]
  # }
}

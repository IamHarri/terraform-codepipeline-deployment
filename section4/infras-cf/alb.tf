module "alb" {
  source                         = "terraform-aws-modules/alb/aws"
  version                        = "8.7.0"
  load_balancer_type             = "application"
  name                           = "${var.repository_name}-loadbalancer"
  vpc_id                         = data.aws_vpc.vpc.id
  subnets                        = data.aws_subnets.subnets.ids
  security_group_use_name_prefix = false
  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress_all_https = {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  target_groups = [
    {
      name               = "instance-${var.repository_name}-http"
      backend_protocol   = "HTTP"
      backend_port       = 80
      target_type        = "instance"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      action_type        = "forward"
      target_group_index = 0
    }
  ]
  # listeners = {
  #   http-listener = {
  #     port     = 80
  #     protocol = "HTTP"
  #     actions = [{
  #       type             = "forward"
  #       target_group_key = "instance-frontend"
  #     }]
  #   }
  # }

  # target_groups = {
  #   instance-frontend = {
  #     name_prefix = "h1"
  #     protocol    = "HTTP"
  #     port        = 80
  #     target_type = "instance"

  #     health_check = {
  #       enabled             = true
  #       interval            = 30
  #       path                = "/"
  #       port                = "traffic-port"
  #       healthy_threshold   = 3
  #       unhealthy_threshold = 3
  #       timeout             = 6
  #       protocol            = "HTTP"
  #       matcher             = "200-399"
  #     }
  #   }
  # }
}

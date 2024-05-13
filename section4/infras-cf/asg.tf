module "asg" {
  source                  = "terraform-aws-modules/autoscaling/aws"
  version                 = "7.4.0"
  name                    = "${var.repository_name}-asg"
  vpc_zone_identifier     = data.aws_subnets.subnets.ids
  min_size                = 1
  max_size                = 1
  desired_capacity        = 1
  default_instance_warmup = 300
  health_check_type       = "EC2"
  instance_type           = "t2.micro"
  image_id                = data.aws_ami.amazon_linux.id
  user_data               = base64encode(data.template_file.user_data.rendered)
  security_groups         = [aws_security_group.sg.id]
  enable_monitoring       = false

  iam_instance_profile_arn = aws_iam_instance_profile.ec2_instance.arn
  block_device_mappings = [{
    device_name = "/dev/xvda"
    no_device   = 0
    ebs = {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 30
      volume_type           = "gp3"
    }
  }]

  target_group_arns = [module.alb.target_group_arns[0]]

  tags = {
    Environment = "dev"
    Application = "${var.repository_name}"
  }
}

resource "aws_iam_instance_profile" "ec2_instance" {
  name = "instance_profile_${var.repository_name}"
  role = aws_iam_role.ec2_instance.name
}

resource "aws_security_group" "sg" {
  name        = "instance_sg_${var.repository_name}"
  description = "Security group for ${var.repository_name} server"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [module.alb.security_group_id]
  }

    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [module.alb.security_group_id]
  }


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_iam_instance_profile" "ec2_instance" {
#   name = "instance_profile_${var.repository_name}"
#   role = aws_iam_role.ec2_instance.name
# }

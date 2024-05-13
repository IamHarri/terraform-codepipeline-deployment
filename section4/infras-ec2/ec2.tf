module "ec2_instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "5.6.1"
  name                        = "${var.repository_name}-instance"
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  user_data                   = data.template_file.user_data.rendered
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance.id
  monitoring                  = false
  vpc_security_group_ids      = [aws_security_group.sg.id]
  # key_name               = aws_key_pair.keypair.key_name

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Application = var.repository_name
  }
}

resource "aws_security_group" "sg" {
  name        = "instance_sg_${var.repository_name}"
  description = "Security group for ${var.repository_name} server"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_iam_instance_profile" "ec2_instance" {
  name = "instance_profile_${var.repository_name}"
  role = aws_iam_role.ec2_instance.name
}

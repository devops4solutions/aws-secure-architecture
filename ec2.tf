resource "aws_launch_template" "nodes" {
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {

      //kms_key_id            = data.aws_kms_key.encryption.arn
      delete_on_termination = true
      volume_type           = "gp2"
      volume_size           = "8"
      encrypted             = true
    }
  }
  name_prefix   = var.environment
  image_id      = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t2.micro"
  user_data = base64encode(templatefile("${path.module}/templates/user_data.tpl", {
    ssh_public_key = var.ssh_public_key
    ansible_user_password = var.ansible_user_password
  }))
  key_name = "ansible"
  network_interfaces {
    security_groups = [aws_security_group.sg.id]
    associate_public_ip_address = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.environment}-asg"
  desired_capacity    = "0"
  max_size            = "0"
  min_size            = "0"
  vpc_zone_identifier = data.aws_subnets.public_subnets.ids
  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 80
    }
  }
  tag {
    key                 = "Name"
    value               = "${var.environment}-node"
    propagate_at_launch = true
  }

}

resource "aws_security_group" "sg" {
  name        = "${lower(var.environment)}-sg"
  description = "Security group for EC2 Instances"
  vpc_id      = module.vpc.vpc_id
  # Ingress rule to allow traffic within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                        # Allows all protocols
    cidr_blocks = [module.vpc.vpc_cidr_block] # VPC CIDR block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg-${var.environment}"
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"] # This matches all subnets with a Name tag
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"] # This matches all subnets with a Name tag
  }
}

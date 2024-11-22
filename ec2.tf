resource "aws_launch_template" "nodes" {
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {

      kms_key_id            = data.aws_kms_key.encryption.arn
      delete_on_termination = true
      volume_type           = "gp2"
      volume_size           = "50"
      encrypted             = true
    }
  }
  name_prefix   = "${var.environment}"
  image_id      = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t2.micro"
  user_data = base64encode(templatefile("${path.module}/templates/user_data.tpl", {
    ssh_public_key = var.ssh_public_key
  }))
  key_name = "ansible.pem"
  network_interfaces {
    security_groups = [aws_security_group.jobmgr_group.id]
  }
}

resource "aws_autoscaling_group" "jobmgr" {
  name                = "${var.environment}-asg"
  desired_capacity    = "1"
  max_size            = "1"
  min_size            = "1"
  vpc_zone_identifier = data.aws_subnets.private.ids
  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage       = 80
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

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_3.id
  subnet_id = data.aws_subnets.private.id
  instance_type = "t2.micro"
  key_name = "ansible.pem"
   user_data = <<-EOF
    #!/bin/bash
    mkdir -p /home/ec2-user/.ssh
    echo "${var.ssh_public_key}" >> /home/ec2-user/.ssh/authorized_keys
    chmod 600 /home/ec2-user/.ssh/authorized_keys
    chmod 700 /home/ec2-user/.ssh
    chown -R ec2-user:ec2-user /home/ec2-user/.ssh
  EOF
}
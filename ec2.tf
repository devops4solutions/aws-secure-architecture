data "aws_ami" "amazon_linux_3" {
  most_recent = true
  owners      = ["137112412989"] # Amazon's official owner ID

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
  tags = {
    Name = "*Private*"
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
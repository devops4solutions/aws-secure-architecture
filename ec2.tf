data "aws_ami" "amazon_linux_3" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["*al2023-ami-kernel-default-x86_64*"]
  }

}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_3.id
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
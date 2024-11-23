#!/bin/bash
mkdir -p /home/ec2-user/.ssh
echo "${ssh_public_key}" >> /home/ec2-user/.ssh/authorized_keys
#!/bin/bash
sudo adduser ansible
echo -e "${ansible_user_password}" | sudo chpasswd
echo 'ansible ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers > /dev/null
sudo -su ansbile
mkdir -p /home/ansible/.ssh
echo "${ssh_public_key}" >> /home/ansible/.ssh/authorized_keys
sudo chmod 600 /home/ansible/.ssh/authorized_keys
sudo chmod 700 /home/ansible/.ssh
sudo chown -R ansible:ansible /home/ansible/.ssh
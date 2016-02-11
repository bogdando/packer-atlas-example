#!/bin/bash -eux
apt-get install -y openssh-server
mkdir -p /var/run/sshd
chmod 0755 /var/run/sshd
echo "UseDNS no" >> /etc/ssh/sshd_config

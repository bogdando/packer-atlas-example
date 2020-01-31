#!/bin/bash -eux
apt-get install -y openssh-server
mkdir -p /var/run/sshd
chmod 0755 /var/run/sshd
echo "UseDNS no" >> /etc/ssh/sshd_config

ssh-keygen -b 1024 -t rsa -f /root/.ssh/id_rsa -N "" -q
ssh-keygen -yf ~/.ssh/id_rsa > /root/.ssh/id_rsa.pub
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

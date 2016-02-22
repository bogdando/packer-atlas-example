#!/bin/bash -eux
# Install crmsh crmsh_2.2.0-1
# to fix https://bugs.launchpad.net/ubuntu/+source/crmsh/+bug/1445616

apt-get -y install wget
wget https://launchpad.net/ubuntu/+source/crmsh/2.2.0-1/+build/8964914/+files/crmsh_2.2.0-1_amd64.deb \
-O /tmp/crmsh_2.2.0-1_amd64.deb
dpkg -i /tmp/crmsh_2.1.4-0ubuntu1_all.deb
exit 0

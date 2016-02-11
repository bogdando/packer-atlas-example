#!/bin/bash -eux
# Install crmsh https://launchpad.net/ubuntu/+source/crmsh/2.1.4-0ubuntu1/+build/8799517
# to fix https://bugs.launchpad.net/ubuntu/+source/crmsh/+bug/1445616

wget https://launchpad.net/ubuntu/+source/crmsh/2.1.4-0ubuntu1/+build/8799517/+files/crmsh_2.1.4-0ubuntu1_all.deb \
-O /tmp/crmsh_2.1.4-0ubuntu1_all.deb
dpkg -i /tmp/crmsh_2.1.4-0ubuntu1_all.deb
exit 0

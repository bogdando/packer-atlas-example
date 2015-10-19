#!/bin/bash -eux

PACKAGES="
crmsh
pcs
pacemaker
corosync
cluster-glue
resource-agents
libqb0
"
# Install corosync with pacemaker
apt-get -y install $PACKAGES

# Enable corosync and pacemaker
sed -i 's/START=no/START=yes/g' /etc/default/corosync
update-rc.d pacemaker start 20 3 4 5 . stop 00 0 1 6 .

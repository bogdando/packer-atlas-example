#!/bin/bash -ux

if [ "${PREBUILT}:-" ]; then
PACKAGES="
resource-agents
"
else
PACKAGES="
pcs
crmsh
pacemaker
corosync
cluster-glue
resource-agents
libqb0
"
fi
# Install corosync with pacemaker
apt-get -y install $PACKAGES

# Enable corosync and pacemaker
sed -i 's/START=no/START=yes/g' /etc/default/corosync
update-rc.d pacemaker start 20 2 3 4 5 . stop 00 0 1 6 .

# Cleanup CIB and nodes info
cibadmin -E -f
crm_node -f -R $(crm_node -i)
cibadmin --delete --xml-text '<node/>'
cibadmin --delete --xml-text '<node_state/>'

sync
exit 0

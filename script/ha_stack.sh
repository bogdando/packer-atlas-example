#!/bin/bash -ux

if [ "${PREBUILT}:-" = 'true' ]; then
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

service corosync start
service pacemaker start
count=0
while [ $count -lt 160 ]                                                                                                                                                          
do
  if timeout --signal=KILL 5 cibadmin -Q
  then
    break
  fi
  count=$((count+10))
  sleep 10
done

# Cleanup CIB and nodes info
cibadmin -E -f
crm_node -f -R $(crm_node -i)
cibadmin --delete --xml-text '<node/>'
cibadmin --delete --xml-text '<node_state/>'

sync
exit 0

#!/bin/sh
# Configures the rabbitmq OCF primitive
# Removes artificial nodes from the CIB.

# Remove artificial nodes from CIB
# wait for crm_node to become functioning
count=0
while [ $count -lt 160 ]
do
  crm_node -l
  [ $? -eq 0 ] && break 
  service pacemaker restart
  sleep 5
done
crm_node -l | awk '{print $2}' > /tmp/valid_nodes
# wait for the crmd to become ready
count=0
while [ $count -lt 160 ]
do
  if crm_attribute --type crm_config --query --name dc-version | grep -q 'dc-version'
  then
    break
  fi
  count=$((count+10))
  sleep 10
done
crm configure show | awk '/^node/ {print $3}' > /tmp/all_nodes
for i in `grep -F -x -v -f /tmp/valid_nodes /tmp/all_nodes` ; do
  crm --force configure delete $i
done

# create the rabbitmq multi-state primitive, remove old node's names artifact
crm configure<<EOF
primitive p_rabbitmq-server ocf:rabbitmq:rabbitmq-server-ha \
        params erlang_cookie=DPMDALGUKEOMPTHWPYKC node_port=5672 \
        op monitor interval=30 timeout=60 \
        op monitor interval=27 role=Master timeout=60 \
        op monitor interval=103 role=Slave timeout=60 OCF_CHECK_LEVEL=30 \
        op start interval=0 timeout=360 \
        op stop interval=0 timeout=120 \
        op promote interval=0 timeout=120 \
        op demote interval=0 timeout=120 \
        op notify interval=0 timeout=180 \
        meta migration-threshold=10 failure-timeout=30s resource-stickiness=100
ms p_rabbitmq-server-master p_rabbitmq-server \
        meta notify=true ordered=false interleave=false master-max=1 master-node-max=1
property stonith-enabled=false
property no-quorum-policy=ignore
commit force
EOF
exit 0

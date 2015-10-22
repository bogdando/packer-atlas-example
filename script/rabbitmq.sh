#!/bin/bash -eux

PACKAGES="
rabbitmq-server
wget
"
# Install corosync with pacemaker
apt-get -y install $PACKAGES

# FIXME(bogdando) remove after the rabbitmq-server v3.5.7 released
wget https://raw.githubusercontent.com/rabbitmq/rabbitmq-server/stable/packaging/common/rabbitmq-server-ha.ocf \
-O /tmp/rabbitmq-server-ha
chmod +x /tmp/rabbitmq-server-ha
cp -f /tmp/rabbitmq-server-ha /usr/lib/ocf/resource.d/rabbitmq/

# stop and disable rabbitmq-server, assumes puppet CM installed
puppet apply -e "service {'rabbitmq-server': ensure=>stopped, enable=>false }"

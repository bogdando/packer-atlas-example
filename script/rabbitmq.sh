#!/bin/bash -eux

PACKAGES="
wget
logrotate
"
# Install corosync with pacemaker
apt-get -y install $PACKAGES

ver=3.6.15
file="rabbitmq-server_${ver}-1_all.deb"
wget "http://www.rabbitmq.com/releases/rabbitmq-server/v${ver}/${file}" -O "/tmp/${file}"
dpkg -i "/tmp/${file}"

# stop and disable rabbitmq-server, assumes puppet CM installed
puppet apply -e "service {'rabbitmq-server': ensure=>stopped, enable=>false }"
sync

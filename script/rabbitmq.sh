#!/bin/bash -eux

apt-get -y install rabbitmq-server

# stop and disable rabbitmq-server, assumes puppet CM installed
puppet apply -e "service {'rabbitmq-server': ensure=>stopped, enable=>false }"
sync

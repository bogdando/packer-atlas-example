#!/bin/bash -eux
# Install the latest erlang packages for a given distro (Xenial/Wily)
distro="${BASE:-ubuntu:xenial}"
apt-get -y install wget
wget -q -O /tmp/erlang-solutions_1.0_all.deb \
  http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
echo "erlang-solutions deb/distro string ${distro}" | \
  debconf-set-selections | dpkg -i /tmp/erlang-solutions_1.0_all.deb
apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y install erlang-nox
sync
exit 0

#!/bin/bash -eux

PACKAGES="
rsync
make
curl
git
rsyslog
psmisc
iputils-ping
iptables
less
wget
vim
screen
tcpdump
strace
sshpass
socat
"
apt-get -y --no-install-recommends install $PACKAGES
sync
exit 0

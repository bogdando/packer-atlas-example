#!/bin/bash -eux

PACKAGES="
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
"
apt-get -y install $PACKAGES
sync
exit 0

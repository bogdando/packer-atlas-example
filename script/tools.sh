#!/bin/bash -eux                                                                                                                                      

PACKAGES="
rsyslog
psmisc
iputils-ping
iptables
less
wget
elvis-tiny
screen
tcpdump
strace
"
apt-get -y install $PACKAGES
exit 0

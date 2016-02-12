#!/bin/bash -eux                                                                                                                                      

PACKAGES="
rsyslog
less
wget
"
# Install corosync with pacemaker
apt-get -y install $PACKAGES
exit 0

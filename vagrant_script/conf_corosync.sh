#!/bin/sh
# Configure ip address of the corosync node as ${1}.${2}
# and wait for ${3} seconds, if requested
[ -z "${1}" -o -z "${2}" ] && exit 1
sed -i "s/bindnetaddr: 127.0.0.1/bindnetaddr: ${1}.${2}/g" /etc/corosync/corosync.conf
[ "${3}" ] && sleep $3
service corosync restart
service pacemaker restart

#!/bin/bash
# Configure hosts entries in the /etc/hosts
[ -z "${1}" ] && exit 1
while (( "$#" )); do
  echo "${1}" >> /etc/hosts
  shift
done
exit 0

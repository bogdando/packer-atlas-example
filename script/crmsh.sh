#!/bin/bash -eux
# Install crmsh crmsh_2.2.0-1 for Xenial, 2.1.4 for Wily
# to fix https://bugs.launchpad.net/ubuntu/+source/crmsh/+bug/1445616
distro="${BASE:-wily}"

apt-get -y install wget
case "${distro}" in
  wily)
    wget https://launchpad.net/ubuntu/+source/crmsh/2.1.4-0ubuntu1/+build/8799517/+files/crmsh_2.1.4-0ubuntu1_all.deb \
    -O /tmp/crmsh_2.1.4-0ubuntu1_all.deb
    dpkg -i /tmp/crmsh_2.1.4-0ubuntu1_all.deb
  ;;
  xenial)
    wget https://launchpad.net/ubuntu/+source/crmsh/2.2.0-1/+build/8964914/+files/crmsh_2.2.0-1_amd64.deb \
    -O /tmp/crmsh_2.2.0-1_amd64.deb
    dpkg -i /tmp/crmsh_2.2.0-1_amd64.deb
  ;;
  *)
    echo The $base is not supported
    exit 1
  ;;
esac
exit 0

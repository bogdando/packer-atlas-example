#!/bin/bash -eux

PACKAGES="
socat
lsof
iproute
libev4
libnuma1
libaio1
libdbd-mysql-perl
libdbi-perl
libev4
libpopt0
libmysqlclient20
mysql-common
netcat-openbsd
galera-3
gawk
libmariadbclient18
libmpfr4
libmysqlclient18
libreadline5
libsigsegv2
mariadb-common
"
apt-get -y --no-install-recommends install $PACKAGES
sync
exit 0

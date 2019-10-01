#!/bin/sh -eux
# Build a wanted ha-stack component from a given repo mounted

[ "${WANTED}" ] || exit 1

build () {
  ./autogen.sh && ./configure && make && make install
}

# include mounted sources repos in the container and cd into
copy_sources () {
  cd /repo/${1}
  mkdir -p /sources/${1}
  rsync -avxH . /sources/${1}
  cd /sources/${1}
}

# a base layer to contain all of the build requirements for HA stack
build_libqb () {
  getent group haclient >/dev/null || groupadd -r haclient
  getent passwd hacluster >/dev/null || useradd -r -g haclient -d /var/lib/heartbeat/cores/hacluster -s /sbin/nologin -c "cluster user" hacluster
  # Need those to generate the service/unit files only
  apt-get -y install corosync pacemaker cluster-glue
  # libqb requirements
  apt-get -y install automake make autoconf autogen pkg-config libgtk-3-dev libtool rsync
  # corosync requirements
  apt-get -y install libnss3-dev
  # pacemaker requirements
  apt-get -y install uuid-dev libxml2-dev libxslt-dev libbz2-dev libcpg-dev libcfg-dev libltdl-dev
  copy_sources libqb
  build
}

# a layer to be based on the libqb
build_corosync () {
  export GROFF=echo
  copy_sources corosync
  build
}

# a layer to be based on the corosync and libqb
build_pacemaker () {
  apt-get -y install libcmap-dev libquorum-dev
  copy_sources pacemaker
  lddconfig -v
  build
}

# a "runner" VM0like container layer to be based on the pacemaker/corosync/libqb and its build deps
build_pcscrm () {
  copy_sources crmsh
  apt-get -y install python-setuptools python-lxml python-yaml python-nosexcover python-dateutil python-pip
  apt-get -y install python3-setuptools python3-lxml python3-openssl python3-tornado python3-yaml python3-nosexcover python3-dateutil python3-pip psmisc python3-pycurl
  pip3 install parallax
  build

  copy_sources pcs
  python3 setup.py build && python3 setup.py install
  test -f /usr/sbin/crm_mon  || ln -s /sbin/crm_mon /usr/sbin/crm_mon
}

###
echo "Build ${WANTED}"
case ${WANTED} in
  libqb)     build_libqb ;;
  corosync)  build_corosync ;;
  pacemaker) build_pacemaker ;;
  pcscrm)    build_pcscrm ;;
  *)         exit 1 ;;
esac
sync

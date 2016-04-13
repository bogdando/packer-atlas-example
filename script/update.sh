#!/bin/bash -eux

if [[ $UPDATE  =~ true || $UPDATE =~ 1 || $UPDATE =~ yes ]]; then
	echo "==> Updating list of repositories"
    # apt-get update does not actually perform updates, it just downloads and indexes the list of packages
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install sudo
    echo "==> Performing dist-upgrade (all packages and kernel)"
    apt-get -y dist-upgrade --force-yes
    sync
    # NOTE(bogdando) Don't do reboot/sleep when used from docker templates.
    # only atlas templates define the VERSION.
    if [ "${VERSION}" ]; then
      reboot
      sleep 160
    fi
fi

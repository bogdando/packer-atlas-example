#!/bin/bash
# A helper script to rebuild libqb->corosync->pacemaker->pcscrm.
# Use a given repo path $1 as well
if [ -z "${1}" ]; then
  echo Specify a git repo path for source code!
  exit 1
fi
cd "${1}"
if ! ls -d {libqb,corosync,pacemaker,pcs,crmsh}; then
  echo A required directory not found, clone it first!
  exit 1
fi
cd -

from=bogdando/libqb
for item in libqb corosync pacemaker; do
  base=$from wanted=$item repo_path="${1}" packer build ha-stack-docker-debian.json
  [ $? -eq 0 ] || break
  from="bogdando/${item}"
done

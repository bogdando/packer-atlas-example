#!/bin/sh
# Install common tools for a runner container
echo 'APT::Install-Suggests "0";' > /tmp/99local
echo 'APT::Install-Recommends "0";' >> /tmp/99local
cp -f /tmp/99local /etc/apt/apt.conf.d/99local
apt-get update || exit 1
[ "${WANTED}" = "pcscrm" ] || exit 0
echo 'APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/99local
echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/99local
PACKAGES="
curl
rsyslog
psmisc
iputils-ping
iptables
less
wget
openssh-server
openssh-client
rsync
strace
lsof
tcpdump
"
apt-get -y install $PACKAGES
mkdir -p /var/run/sshd
chmod 0755 /var/run/sshd
echo "UseDNS no" >> /etc/ssh/sshd_config

curl -sSL https://get.docker.com/ | sh

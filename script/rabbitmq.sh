#!/bin/bash -eux

apt-get install apt-transport-https -y
apt-get install curl gnupg debian-keyring debian-archive-keyring apt-transport-https -y

## Team RabbitMQ's main signing key
set +e
apt-key adv --keyserver "hkps://keys.openpgp.org" --recv-keys "0x0A9AF2115F4687BD29803A206B73A36E6026DFCA"
set -e
## Launchpad PPA that provides modern Erlang releases
apt-key adv --keyserver "keyserver.ubuntu.com" --recv-keys "F77F1EDA57EBB1CC"
## PackageCloud RabbitMQ repository
curl -1sLf 'https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey' | apt-key add -

erlbase="debian/ buster"
if [[ "$BASE" =~ "ubuntu" ]]; then
  erlbase="ubuntu/ jammy"
  tee /etc/apt/sources.list.d/rabbitmq-erlang-launchpad.list <<EOF
## Provides modern Erlang/OTP releases
##
## "bionic" as distribution name should work for any reasonably recent Ubuntu or Debian release.
deb http://ppa.launchpad.net/rabbitmq/rabbitmq-erlang/${erlbase} main
deb-src http://ppa.launchpad.net/rabbitmq/rabbitmq-erlang/${erlbase} main
EOF
fi

tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides RabbitMQ
##
deb https://packagecloud.io/rabbitmq/rabbitmq-server/${erlbase} main
deb-src https://packagecloud.io/rabbitmq/rabbitmq-server/${erlbase} main
EOF

if [[ "$BASE" =~ "debian" ]]; then
  # Erlang 24 (bionic)
  erlbase=bionic
  # TODO: Erlang 23 (xenial) that requires libssl1.0, which is not in Debian Buster
  #erlbase=xenial
  curl -1sLf 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/gpg.E495BB49CC4BBE5B.key' | apt-key add -
  curl -1sLf "https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/config.deb.txt?distro=ubuntu&codename=${erlbase}" > /etc/apt/sources.list.d/rabbitmq-erlang-cloudsmith.list

  # Prefer erl 23 from cloudsmith
  tee /etc/apt/preferences.d/erlang <<EOF
Package: erlang*
Pin: origin dl.cloudsmith.io
Pin-Priority: 1000
EOF
fi
apt-get update -y
apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl
apt-get install rabbitmq-server -y --fix-missing

# stop and disable rabbitmq-server, assumes puppet CM installed
puppet apply -e "service {'rabbitmq-server': ensure=>stopped, enable=>false }"
sync

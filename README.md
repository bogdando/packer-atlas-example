# RabbitMQ cluster OCF packer template

[![Circle CI](https://circleci.com/gh/bogdando/packer-atlas-example.svg?style=svg)](https://circleci.com/gh/bogdando/packer-atlas-example)
| [RabbitMQ Cluster Atlas Vagrant Boxes (Ubuntu 14.04)](https://atlas.hashicorp.com/bogdando/boxes/rabbitmq-cluster-ocf)
| [RabbitMQ Cluster Docker Image (Ubuntu 15.10)](https://hub.docker.com/r/bogdando/rabbitmq-cluster-ocf-wily/)
| [RabbitMQ Cluster Docker Image (Ubuntu 16.04)](https://hub.docker.com/r/bogdando/rabbitmq-cluster-ocf-xenial/)
| [RabbitMQ Cluster Image Atlas Builds](https://atlas.hashicorp.com/bogdando/build-configurations/rabbitmq-cluster-ocf)
| [Vagrantfile for a fast RabbitMQ cluster](https://github.com/bogdando/rabbitmq-cluster-ocf-vagrant)
| [Pacemaker Cluster Docker Image (Ubuntu 15.10)](https://hub.docker.com/r/bogdando/pacemaker-cluster-ocf-wily/)
| [Pacemaker Cluster Docker Image (Ubuntu 16.04)](https://hub.docker.com/r/bogdando/pacemaker-cluster-ocf-xenial/)

This is a RabbitMQ Cluster/Generic Pacemaker node template to build a Vagrant Box and
a Docker Image with Packer and push it to Atlas/DockerHub.
See more details in [Stefan Scherer's blog post](https://stefanscherer.github.io/automate-building-vagrant-boxes-with-atlas/).

The automated build is triggered by a WebHook in GitHub to start a build in
CircleCI that triggers a packer build and pushes with `packer push` which
builds an Atlas box.
FIXME(bogdando) pushing is working only to atlas at the moment.

* To disable or enable `push all`, set the `PUSH` param in the ``circle.yaml``
  to `false` or `true`.

## CircleCI template

See the `circle.yml` for details how the glue works. It just installs packer
0.8.1, enables docker service, and starts the `packer push`, if pushing is
enabled.

## RabbitMQ and Pacemaker clusters packer templates

Builds the Vagrant Box for Atlas for the rabbitmq clustering features testing.
See the ``rabbitmq-cluster-ocf.json`` with the post-processors section with all
details about deploying.

The ``rabbitmq-cluster-ocf-docker-ubuntu.json`` also builds a Docker Image based
on Ubuntu 15.10 Wily or 16.04 Xenial with Erlang, RabbitMQ and some other packages.
Setup the `base` env var as either `wily` or `xenial` to get the required build
type, for example:

```
$headless=true base=wily packer build -only=docker -color=false \
rabbitmq-cluster-ocf-docker-ubuntu.json
```

If you want to build only a Corosync/Pacemaker cluster setup on top of
Ubuntu, use the ``pacemaker-cluster-ocf-docker-ubuntu.json``.

## Caching for builds

There are distro base specific shared volumes for docker build templates. For Ubuntu,
those are mounts for `/var/cache` and /var/lib/apt`. For example, for ``base=wily``,
the volumes `lib_apt_wily` and `cache_wily` will be used across consequent
packer builds, hopefully making things faster. If something is wrong, just
remove the volumes to be rebuilt from the scratch.

## Vagrantfile

Moved [here](https://github.com/bogdando/rabbitmq-cluster-ocf-vagrant).
It allows to bootstrap a cluster and perform smoke/jepsen tests.
See also a generic
[Vagrantfile](https://github.com/bogdando/pacemaker-cluster-ocf-vagrant)
for a given Pacemaker OCF RA resource under test.

## Acknowledgements

The Packer template and provision scripts are based on box-cutter/ubuntu-vm.
Check out the more up to date version at [github.com/boxcutter](https://github.com/boxcutter).

The packer templates and provision scripts in this fork are based
on the original repo StefanScherer/packer-atlas-example and on the
jakobadam/packer-qemu-templates.

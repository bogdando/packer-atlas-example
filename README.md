# RabbitMQ cluster OCF packer template

[![Circle CI](https://circleci.com/gh/bogdando/packer-atlas-example.svg?style=svg)](https://circleci.com/gh/bogdando/packer-atlas-example)
| [Atlas Builds](https://atlas.hashicorp.com/bogdando/build-configurations/rabbitmq-cluster-ocf)
| [Atlas Vagrant Boxes](https://atlas.hashicorp.com/bogdando/boxes/rabbitmq-cluster-ocf)

This is a RabbitMQ node template to build a Vagrant Box with Packer in Atlas.
See more details in [Stefan Scherer's blog post](https://stefanscherer.github.io/automate-building-vagrant-boxes-with-atlas/).

The automated build is triggered by a WebHook in GitHub to start a build in CircleCI
that triggers a build in Atlas with `packer push`.

## CircleCI template
See the `circle.yml` for details how the glue works. It just installs packer 0.8.1
and starts the `packer push`.

## RabbitMQ cluster OCF packer template

Builds the Vagrant Box for Atlas for the rabbitmq clustering features testing.
See the `rabbitmq-cluster-ocf.json` with the post-processors section with all details about
deploying the Vagrant Box to Atlas.

Also builds the docker image, though it must be pushed manually (TODO circle CI
job auth for the dockerhub).

## Vagrantfile

Supports libvirt, virtualbox, docker providers.
Spins up two VM nodes [n1, n2] with predefined IP addressess 10.10.10.2-3/24.
Creates a corosync cluster with disabled quorum and STONITH.
Launches a rabbitmq OCF multi-state pacemaker clone which should assemble
the rabbit cluster automatically.

## Known issues

* For the docker provider, a networking is [not implemented](https://github.com/mitchellh/vagrant/issues/6667)
  and there is no [docker-exec privisioner](https://github.com/mitchellh/vagrant/issues/4179)
  to replace the SSH-based one. So I put ugly workarounds all around to make things working.

* Use ``docker rm -f -v`` if ``vagrant destroy`` fails to teardown things.

* The ``vagrant up`` may through en error about a bad ssh exit code. Just ignore it
  and perform the manual action up for the rest of the nodes (n2, n3, etc.), if required.

* Make sure there is no conflicting host networks exist like `packer-atlas-example0`
  or `vagrant-libvirt` or the like. Otherwise nodes become isolated from the host system.

## Acknowledgements

The Packer template and provision scripts are based on box-cutter/ubuntu-vm.
Check out the more up to date version at [github.com/boxcutter](https://github.com/boxcutter).

The Rabbit cluster OCF template and provision scripts in this fork are based on the
original repo StefanScherer/packer-atlas-example and on the jakobadam/packer-qemu-templates.

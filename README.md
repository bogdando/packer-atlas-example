# RabbitMQ cluster OCF packer template

[![Circle CI](https://circleci.com/gh/bogdando/packer-atlas-example.svg?style=svg)](https://circleci.com/gh/bogdando/packer-atlas-example)
| [RabbitMQ Pacemaker OCF RA Docs](http://www.rabbitmq.com/pacemaker.html)
| [Atlas Vagrant Boxes (Ubuntu 14.04)](https://atlas.hashicorp.com/bogdando/boxes/rabbitmq-cluster-ocf)
| [Docker Image (Ubuntu 15.10)](https://hub.docker.com/r/bogdando/rabbitmq-cluster-ocf-wily/)
| [Docker Image (Ubuntu 16.04)](https://hub.docker.com/r/bogdando/rabbitmq-cluster-ocf-xenial/)
| [Atlas Builds](https://atlas.hashicorp.com/bogdando/build-configurations/rabbitmq-cluster-ocf)

This is a RabbitMQ clustered node template to build a Vagrant Box and
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

## RabbitMQ cluster OCF packer templates

Builds the Vagrant Box for Atlas for the rabbitmq clustering features testing.
See the ``rabbitmq-cluster-ocf.json`` with the post-processors section with all
details about deploying.

The ``rabbitmq-cluster-ocf-docker-ubuntu.json`` also builds a Docker Image based
on Ubuntu 15.10 Wily or 16.04 Xenial. Setup the `base` env var as either `wily` or
`xenial` to get the required build type, for example:

```
$headless=true base=wily packer build -only=docker -color=false \
rabbitmq-cluster-ocf-docker-ubuntu.json
```

## Vagrantfile

Moved to the https://github.com/bogdando/rabbitmq-cluster-ocf-vagrant .
It allows to bootstrap a cluster and perform a smoke test.

## Acknowledgements

The Packer template and provision scripts are based on box-cutter/ubuntu-vm.
Check out the more up to date version at [github.com/boxcutter](https://github.com/boxcutter).

The Rabbit cluster OCF template and provision scripts in this fork are based
on the original repo StefanScherer/packer-atlas-example and on the
jakobadam/packer-qemu-templates.

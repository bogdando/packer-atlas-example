# RabbitMQ cluster OCF packer template

[![Circle CI](https://circleci.com/gh/bogdando/packer-atlas-example.svg?style=svg)](https://circleci.com/gh/bogdando/packer-atlas-example)
| [Atlas Builds](https://atlas.hashicorp.com/bogdando/build-configurations/packer-atlas-example)
| [Atlas Vagrant Boxes](https://atlas.hashicorp.com/bogdando/boxes/rabbitmq-cluster-ocf)

This is a RabbitMQ node template to build a Vagrant Box with Packer in Atlas.
See more details in [Stefan Scherer's blog post](https://stefanscherer.github.io/automate-building-vagrant-boxes-with-atlas/).

The automated build is triggered by a WebHook in GitHub to start a build in CircleCI
that triggers a build in Atlas with `packer push`.

## Packer template

See the `rabbitmq-cluster-ocf.json` with the post-processors section with all details about
deploying the Vagrant Box to Atlas.

## circle.yml
See the `circle.yml` for details how the glue works. It just installs packer 0.8.1
and starts the `packer push`.

## RabbitMQ cluster OCF packer template

Builds the Vagrant Box (vbox/libvirt) for Atlas for the clustering features testing.

## Acknowledgements

The Packer template and provision scripts are based on box-cutter/ubuntu-vm.
Check out the more up to date version at [github.com/boxcutter](https://github.com/boxcutter).

The Rabbit cluster OCF template and provision scripts in this fork are based on the
original repo StefanScherer/packer-atlas-example and on the jakobadam/packer-qemu-templates.

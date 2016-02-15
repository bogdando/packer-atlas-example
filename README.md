# RabbitMQ cluster OCF packer template

[![Circle CI](https://circleci.com/gh/bogdando/packer-atlas-example.svg?style=svg)](https://circleci.com/gh/bogdando/packer-atlas-example)
| [RabbitMQ Pacemaker OCF RA Docs](http://www.rabbitmq.com/pacemaker.html)
| [Atlas Vagrant Boxes (Ubuntu 14.04)](https://atlas.hashicorp.com/bogdando/boxes/rabbitmq-cluster-ocf)
| [Docker Image (Ubuntu 14.04)](https://hub.docker.com/r/bogdando/rabbitmq-cluster-ocf/)
| [Docker Image (Ubuntu 15.10)](https://hub.docker.com/r/bogdando/rabbitmq-cluster-ocf-wily/) 
| [Atlas Builds](https://atlas.hashicorp.com/bogdando/build-configurations/rabbitmq-cluster-ocf)

This is a RabbitMQ clustered node template to build a Vagrant Box and
a Docker Image with Packer and push it to Atlas/DockerHub.
See more details in [Stefan Scherer's blog post](https://stefanscherer.github.io/automate-building-vagrant-boxes-with-atlas/).

The automated build is triggered by a WebHook in GitHub to start a build in
CircleCI that triggers a packer build and pushes with `packer push` both
to Atlas and DockerHub.

FIXME(bogdando) pushing is working only manually at the moment. CI job seems
broken ;(

* To disable or enable `push all`, set the `PUSH` param in the ``circle.yaml``
  to `false` or `true`.
* To push only atlas builds for Ubuntu 14.04, set it to `trusty` or `atlas`.
* And to push only docker builds for Ubuntu 15.10, use `wily` or `docker`.

## CircleCI template

See the `circle.yml` for details how the glue works. It just installs packer
0.8.1, enables docker service, and starts the `packer push`, if pushing is
enabled.

## RabbitMQ cluster OCF packer templates

Builds the Vagrant Box for Atlas for the rabbitmq clustering features testing.
See the ``rabbitmq-cluster-ocf.json`` with the post-processors section with all
details about deploying.

The ``rabbitmq-cluster-ocf-docker-wily.json`` also builds the Docker Image based on
Ubuntu 15.10 Wily.

## Vagrantfile

Supports libvirt, virtualbox, docker providers.
Reguired plugins: vagrant-triggers, vagrant-libvirt.

* Spins up two VM nodes ``[n1, n2]`` with predefined IP addressess
  ``10.10.10.2-3/24`` by default.
* Creates a corosync cluster with disabled quorum and STONITH.
* Launches a rabbitmq OCF multi-state pacemaker clone which should assemble
  the rabbit cluster automatically.
* Generates a command for a smoke test for the rabbit cluster. This shall be
  run on one of the nodes (n1, n2, etc.) running.

Note, that constants from the ``Vagrantfile`` may be as well configred as
environment variables. Also note, that for the docker wily image, ssh server is
not installed.

## Known issues

* For the docker provider, use the image based on Ubuntu 15.10. It has
  Pacemaker 1.1.12, while the image with Ubuntu 14.10 contains Pacemaker 1.1.10
  and there is stability issue which renders the pacemakerd daemon stopping
  sporadically, therefore the RabbitMQ cluster does not assemble well.

* For the docker provider, a networking is [not implemented](https://github.com/mitchellh/vagrant/issues/6667)
  and there is no [docker-exec privisioner](https://github.com/mitchellh/vagrant/issues/4179)
  to replace the ssh-based one. So I put ugly workarounds all around to make
  things working more or less.

* Use ``docker rm -f -v`` if ``vagrant destroy`` fails to teardown things.

* if ``vagrant ssh n1`` fails, use the command
  ```
  docker exec -it n1 bash
  ```

* The ``vagrant up`` may through en error about a bad ssh exit code. Just
  ignore it and perform the manual action up for the rest of the nodes
  (n2, n3, etc.), if required.

* Make sure there is no conflicting host networks exist, like
  ``packer-atlas-example0`` or ``vagrant-libvirt`` or the like. Otherwise nodes may
  become isolated from the host system.

## Troubleshooting

You may want to use the command like:
```
VAGRANT_LOG=info SLAVES_COUNT=2 vagrant up --provider docker 2>&1| tee out
```

There was added "Crafted:", "Executing:" log entries for the
provision shell scripts.

For the Rabbitmq OCF RA you may use the command like:
```
OCF_ROOT=/usr/lib/ocf /usr/lib/ocf/resource.d/rabbitmq/rabbitmq-server-ha monitor
```

## Acknowledgements

The Packer template and provision scripts are based on box-cutter/ubuntu-vm.
Check out the more up to date version at [github.com/boxcutter](https://github.com/boxcutter).

The Rabbit cluster OCF template and provision scripts in this fork are based
on the original repo StefanScherer/packer-atlas-example and on the
jakobadam/packer-qemu-templates.

# RabbitMQ cluster OCF packer template

[![Circle CI](https://circleci.com/gh/bogdando/packer-atlas-example.svg?style=svg)](https://circleci.com/gh/bogdando/packer-atlas-example)
| [RabbitMQ Cluster Docker VM Image (Debian)](https://hub.docker.com/r/bogdando/rabbitmq-cluster-ocf/)
| [Vagrantfile for a fast RabbitMQ cluster](https://github.com/bogdando/rabbitmq-cluster-ocf-vagrant)

This is a collection of packer templates for a RabbitMQ/Pacemaker VM nodes and docker VM-like containers.
It also contains templates to build a Libqb/Corosync/Pacemaker (Linux HA stack) as a lightweight docker apps.

For Packer to Atlas and CI integration examples, see
[Stefan Scherer's blog post](https://stefanscherer.github.io/automate-building-vagrant-boxes-with-atlas/).

The automated build is triggered by a WebHook in GitHub to start a build in
CircleCI that triggers a packer build and pushes the produced container image
to DockerHub.

## CircleCI template

See the `.circleci/config.yml` for details how the glue works.

## RabbitMQ and Pacemaker VM nodes packer templates

Builds a docker image for the RabbitMQ RA OCF clustering features testing.  The
``rabbitmq-cluster-ocf-docker.json`` builds a Docker VM image either based on a
prebuilt image with Linux HA stack or some other image, with Erlang, RabbitMQ
and some other packages. Setup the `base` env var as either `debian:latest` or
optionally use `base=bogdando/pcscrm prebuilt=1` to get the required build type,
for example:

```
$headless=true base=debian:latest packer build -only=docker -color=false \
rabbitmq-cluster-ocf-docker.json

$base=ubuntu:latest prebuilt=yes packer build -only=docker \
rabbitmq-cluster-ocf-docker.json
```

If you don't have a prebuilt image but want to install only a Corosync/Pacemaker from
packages use ``pacemaker-cluster-ocf-docker.json``.

## Corosync/Pacemaker apps and CLI tools packer templates (obsolete/no longer used)

Builds from trunc the DockerHub images for a Corosync/Pacemaker apps and a runner
container containing related HA stack/generic tools like pcs, crm, wget, iptables.
Unlike to the templates above creating a "heavies", a VM-like containers, the apps
are a lightweight docker containers. The runner is still a "heavy" VM-like
though.

Allowed values for the `wanted` are libqb, corosync, pacemaker, pcscrm.
And for the `base`: debian:latest (or perhaps anything suchlike), bogdando/libqb,
bogdando/corosync, bogdando/pacemaker, bogdando/pcssrm.

The build chain is supposed to be as the following:
* To build the libqb libs container, use `base=debian:latest wanted=libqb`
  (or `base=bogdando/libqb`, if you don't want to go from the clean debian again)
* To build the corosync, use `base=bogdando/libqb wanted=corosync`
* To build the pacemaker container, use `base=bogdando/corosync wanted=pacemaker`
* And for the pcssrm runner container, use `base=bogdando/pacemaker wanted=pcscrm`.

Note, you can try to build the runner from another bases, although it might
require additional dependencies to be installed.

F.e. to "rebase" the corosync on top of the changed libqb, run:
```
$headless=true base=bogdando/libqb wanted=corosync \
repo_path=/home/fuser/gitrepos/ packer build ha-stack-docker.json
```

And to rebuild the corosync leaving the libqb base as is, use:
```
$headless=true base=bogdando/corosync wanted=corosync \
repo_path=/home/fuser/gitrepos/ packer build ha-stack-docker.json
```

Make sure the required source repos (or extracted signed tarballs), which is
ones for a libqb, corosync, pacemaker, crmsh and pcs (named exactly the same way
as listed here) present at a given `repo_path`.
Also use the `rebuild-ha-stack.sh` script to rebuild all but the pcscrm.

## Caching for builds

There are distro base specific shared volumes for docker build templates. For Ubuntu,
those are mounts for `/var/cache` and /var/lib/apt`. For example, for ``base=foo``,
the volumes ``lib_apt_foo`` and ``cache_foo`` will be used across consequent
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

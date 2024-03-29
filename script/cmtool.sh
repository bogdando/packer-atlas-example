#!/bin/bash -eux

# CM and CM_VERSION variables should be set inside of the Packer template:
#
# Values for CM can be:
#   'nocm'               -- build a box without a configuration management tool
#   'chef'               -- build a box with Chef
#   'chefdk'             -- build a box with Chef Development Kit
#   'salt'               -- build a box with Salt
#   'puppet'             -- build a box with Puppet
#
# Values for CM_VERSION can be (when CM is chef|chefdk|salt|puppet):
#   'x.y.z'              -- build a box with version x.y.z of Chef
#   'x.y'                -- build a box with version x.y of Salt
#   'x.y.z-apuppetlabsb' -- build a box with package version of Puppet
#   'latest'             -- build a box with the latest version
#
# Set CM_VERSION to 'latest' if unset because it can be problematic
# to set variables in pairs with Packer (and Packer does not support
# multi-value variables).
CM_VERSION=${CM_VERSION:-latest}

#
# Provisioner installs.
#

install_chef()
{
    echo "==> Installing Chef"
    if [[ ${CM_VERSION} == 'latest' ]]; then
        echo "Installing latest Chef version"
        curl -Lk https://www.getchef.com/chef/install.sh | bash
    else
        echo "Installing Chef version ${CM_VERSION}"
        curl -Lk https://www.getchef.com/chef/install.sh | bash -s -- -v $CM_VERSION
    fi
}

install_chef_dk()
{
    echo "==> Installing Chef Development Kit"
    if [[ ${CM_VERSION:-} == 'latest' ]]; then
        echo "==> Installing latest Chef Development Kit version"
        curl -Lk https://www.getchef.com/chef/install.sh | sh -s -- -P chefdk
    else
        echo "==> Installing Chef Development Kit ${CM_VERSION}"
        curl -Lk https://www.getchef.com/chef/install.sh | sh -s -- -P chefdk -v ${CM_VERSION}
    fi

    echo "==> Adding Chef Development Kit and Ruby to PATH"
    echo 'eval "$(chef shell-init bash)"' >> /home/vagrant/.bash_profile
    chown vagrant /home/vagrant/.bash_profile
}

install_salt()
{
    echo "==> Installing Salt"
    if [[ ${CM_VERSION:-} == 'latest' ]]; then
        echo "Installing latest Salt version"
        wget -O - http://bootstrap.saltstack.org | sudo sh
    else
        echo "Installing Salt version $CM_VERSION"
        curl -L http://bootstrap.saltstack.org | sudo sh -s -- git $CM_VERSION
    fi
}

install_puppet()
{
    echo "==> Installing Puppet"
    . /etc/lsb-release

    DEB_NAME=puppet6-release-$(lsb_release -c -s).deb
    wget http://apt.puppetlabs.com/${DEB_NAME}
    dpkg -i ${DEB_NAME}
    apt-get update
    if [[ ${CM_VERSION:-} == 'latest' ]]; then
      echo "Installing latest Puppet version"
      apt-get install -y puppet
    else
      echo "Installing Puppet version $CM_VERSION"
      apt-get install -y puppet-common=$CM_VERSION puppet=$CM_VERSION
    fi
    rm -f ${DEB_NAME}

    # Install puppet-librarian
    echo "==> Installing Puppet-librarian ruby gem"
    apt-get install -y make
    apt-get install -y ruby-dev
    gem install --force librarian-puppet
}

install_ansible()
{
    echo "==> Installing Ansible python egg"
    # TODO(bogdando): maybe this is better:
    # http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-apt-ubuntu
    apt-get remove -f python-pip
    sudo apt-get install -y python-setuptools
    sudo easy_install pip
    sudo pip install -U pip
    sudo pip install ansible
}

#
# Main script
#

case "${CM}" in
  'chef')
    install_chef
    ;;

  'chefdk')
    install_chef_dk
    ;;

  'salt')
    install_salt
    ;;

  'puppet')
    install_puppet
    ;;

  'ansible')
    install_ansible
    ;;

  *)
    echo "==> Building box without baking in a configuration management tool"
    ;;
esac

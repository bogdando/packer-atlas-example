# -*- mode: ruby -*-
# vi: set ft=ruby :

SLAVES_COUNT=1
IMAGE_NAME="bogdando/rabbitmq-cluster-ocf"
IP24NET="10.10.10"

def shell_script(filename, args=[])
  "/bin/bash #{filename} #{args.join ' '} 2>/dev/null"
end

# Render a rabbitmq pacemaker primitive configuration
rabbit_primitive_setup = shell_script("/vagrant/vagrant_script/conf_rabbit_primitive.sh")

# FIXME(bogdando) remove rendering rabbitmq OCF script setup after v3.5.7 released
rabbit_ocf_setup = shell_script("/vagrant/vagrant_script/conf_rabbit_ocf.sh")

# Render hosts entries
entries = "\"#{IP24NET}.2 n1 n1\""
SLAVES_COUNT.times do |i|
  index = i + 2
  ip_ind = i + 3
  raise if ip_ind > 254
  entries += " \"#{IP24NET}.#{ip_ind} n#{index} n#{index}\""
end
hosts_setup = shell_script("/vagrant/vagrant_script/conf_hosts.sh", [entries])

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.define "n1", primary: true do |config|
    config.vm.box = IMAGE_NAME
    config.vm.host_name = "n1"
    config.vm.network :private_network, ip: "#{IP24NET}.2", :mode => 'nat'
    config.vm.provision "shell", run: "always", inline: hosts_setup, privileged: true
    corosync_setup = shell_script("/vagrant/vagrant_script/conf_corosync.sh", ["#{IP24NET}.2"])
    config.vm.provision "shell", run: "always", inline: corosync_setup, privileged: true
    config.vm.provision "shell", run: "always", inline: rabbit_ocf_setup, privileged: true
    config.vm.provision "shell", run: "always", inline: rabbit_primitive_setup, privileged: true
  end

  SLAVES_COUNT.times do |i|
    index = i + 2
    ip_ind = i + 3
    raise if ip_ind > 254
    config.vm.define "n#{index}" do |config|
      config.vm.box = IMAGE_NAME
      config.vm.host_name = "n#{index}"
      config.vm.provision "shell", run: "always", inline: hosts_setup, privileged: true
      config.vm.network :private_network, ip: "#{IP24NET}.#{ip_ind}", :mode => 'nat'
      # wait 10 seconds for the first corosync node
      corosync_setup = shell_script("/vagrant/vagrant_script/conf_corosync.sh", ["#{IP24NET}.#{ip_ind}", 10])
      config.vm.provision "shell", run: "always", inline: corosync_setup, privileged: true
      config.vm.provision "shell", run: "always", inline: rabbit_ocf_setup, privileged: true
    end
  end
end

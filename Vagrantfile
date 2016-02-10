# -*- mode: ruby -*-
# vi: set ft=ruby :

SLAVES_COUNT=(ENV['SLAVES_COUNT'] || '1').to_i
IMAGE_NAME=ENV['IMAGE_NAME'] || "bogdando/rabbitmq-cluster-ocf"
IP24NET=ENV['IP24NET'] || "10.10.10"

# FIXME(bogdando) more natively to distinguish a provider specific logic
provider = (ARGV[2] || ENV['VAGRANT_DEFAULT_PROVIDER'] || :docker).to_sym

def shell_script(filename, args=[])
  "/bin/bash #{filename} #{args.join ' '} 2>/dev/null"
end

# Render a rabbitmq pacemaker primitive configuration
rabbit_primitive_setup = shell_script("/vagrant/vagrant_script/conf_rabbit_primitive.sh")

# FIXME(bogdando) remove rendering rabbitmq OCF script setup after v3.5.7 released
rabbit_ocf_setup = shell_script("/vagrant/vagrant_script/conf_rabbit_ocf.sh")

if provider == :docker
  # FIXME(bogdando) ugly hack as there is no vm.network for the docker provider
  # get the IP range from the default bridge docker network
  begin
    docker_inspect = `docker network inspect bridge`
    net = docker_inspect.match(/((\d+\.){2}\d+)\.\d+\/16/)[1]
  rescue
    raise("Cannot configure the /24 subnet for the default docker bridge network!")
  end
end

# Render hosts entries
entries = "\"#{net}.2 n1 n1\""
SLAVES_COUNT.times do |i|
  index = i + 2
  ip_ind = i + 3
  raise if ip_ind > 254
  entries += " \"#{net}.#{ip_ind} n#{index} n#{index}\""
end
hosts_setup = shell_script("/vagrant/vagrant_script/conf_hosts.sh", [entries])

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  if provider == :docker then
    config.vm.provider :docker do |d, override|
      d.image = IMAGE_NAME
      d.remains_running = false
      d.has_ssh = true
      d.cmd = ["/usr/sbin/sshd", "-D"]
      d.create_args = ["-i", "-t"]
    end
  else
    config.vm.box = IMAGE_NAME
    net=IP24NET
  end

  config.vm.define "n1", primary: true do |config|
    config.vm.host_name = "n1"
    #NOTE(bogdnado) vm.network is not implemented for the docker provider
    config.vm.network :private_network, ip: "#{net}.2", :mode => 'nat'
    config.vm.provision "shell", run: "always", inline: hosts_setup, privileged: true
    corosync_setup = shell_script("/vagrant/vagrant_script/conf_corosync.sh", ["#{net}.2"])
    config.vm.provision "shell", run: "always", inline: corosync_setup, privileged: true
    config.vm.provision "shell", run: "always", inline: rabbit_ocf_setup, privileged: true
    config.vm.provision "shell", run: "always", inline: rabbit_primitive_setup, privileged: true
  end

  SLAVES_COUNT.times do |i|
    index = i + 2
    ip_ind = i + 3
    raise if ip_ind > 254
    config.vm.define "n#{index}" do |config|
      config.vm.host_name = "n#{index}"
      config.vm.provision "shell", run: "always", inline: hosts_setup, privileged: true
      config.vm.network :private_network, ip: "#{net}.#{ip_ind}", :mode => 'nat'
      # wait 10 seconds for the first corosync node
      corosync_setup = shell_script("/vagrant/vagrant_script/conf_corosync.sh", ["#{net}.#{ip_ind}", 10])
      config.vm.provision "shell", run: "always", inline: corosync_setup, privileged: true
      config.vm.provision "shell", run: "always", inline: rabbit_ocf_setup, privileged: true
    end
  end
end

# -*- mode: ruby -*-
# vi: set ft=ruby :

SLAVES_COUNT=(ENV['SLAVES_COUNT'] || '1').to_i
IMAGE_NAME=ENV['IMAGE_NAME'] || "bogdando/rabbitmq-cluster-ocf"
IP24NET=ENV['IP24NET'] || "10.10.10"
DOCKER_NET=ENV['DOCKER_NET'] || "rabbits"

# FIXME(bogdando) more natively to distinguish a provider specific logic
provider = (ARGV[2] || ENV['VAGRANT_DEFAULT_PROVIDER'] || :docker).to_sym
# Install required plugins
%w(vagrant-libvirt vagrant-triggers).each do |p|
  system <<-SCRIPT
  if ! vagrant plugin list | grep -q "#{p}" ; then
    vagrant plugin install "#{p}"
  fi
  SCRIPT
end

def shell_script(filename, args=[])
  "/bin/bash #{filename} #{args.join ' '} 2>/dev/null"
end

# W/a unimplemented docker-exec, see https://github.com/mitchellh/vagrant/issues/4179
# Use docker exec instead of the SSH provisioners
def docker_exec (name, script)
  puts "exec at #{name}: #{script}"
  system "docker exec -it #{name} #{script}"
end

# Render a rabbitmq pacemaker primitive configuration
rabbit_primitive_setup = shell_script("/vagrant/vagrant_script/conf_rabbit_primitive.sh")

# FIXME(bogdando) remove rendering rabbitmq OCF script setup after v3.5.7 released
# and got to the UCA packages
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
  if provider == :docker
    # W/a unimplemented docker networking, see
    # https://github.com/mitchellh/vagrant/issues/6667.
    # Create or delete the DOCKER_NET (depends on the vagrant action)
    config.trigger.before :up do
      system <<-SCRIPT
      if ! docker network inspect #{DOCKER_NET} >/dev/null 2>&1 ; then
        docker network create -d bridge \
          -o "com.docker.network.bridge.enable_icc"="true" \
          -o "com.docker.network.bridge.enable_ip_masquerade"="true" \
          -o "com.docker.network.driver.mtu"="1500" \
          --gateway=#{IP24NET}.1 \
          --ip-range=#{IP24NET}.0/24 \
          --subnet=#{IP24NET}.0/24 \
          #{DOCKER_NET} >/dev/null 2>&1
      fi
      SCRIPT
    end
    config.trigger.after :destroy do
      system <<-SCRIPT
      docker network rm #{DOCKER_NET} >/dev/null 2>&1
      SCRIPT
    end

    config.vm.provider :docker do |d, override|
      d.image = IMAGE_NAME
      d.remains_running = false
      d.has_ssh = false
      d.cmd = ["/usr/sbin/sshd", "-D"]
    end
  else
    config.vm.box = IMAGE_NAME
  end

  config.vm.define "n1", primary: true do |config|
    config.vm.host_name = "n1"
    corosync_setup = shell_script("/vagrant/vagrant_script/conf_corosync.sh", ["#{IP24NET}.2"])
    if provider == :docker
      config.vm.provider :docker do |d, override|
        d.name = "n1"
        d.create_args = ["-i", "-t", "--privileged", "--ip=#{IP24NET}.2", "--net=#{DOCKER_NET}"]
      end
      config.trigger.after :up do
        docker_exec("n1","#{hosts_setup}")
        docker_exec("n1","#{corosync_setup}")
        docker_exec("n1","#{rabbit_ocf_setup}")
        docker_exec("n1","#{rabbit_primitive_setup}")
      end
    else
      config.vm.network :private_network, ip: "#{IP24NET}.2", :mode => 'nat'
      config.vm.provision "shell", run: "always", inline: hosts_setup, privileged: true
      config.vm.provision "shell", run: "always", inline: corosync_setup, privileged: true
      config.vm.provision "shell", run: "always", inline: rabbit_ocf_setup, privileged: true
      config.vm.provision "shell", run: "always", inline: rabbit_primitive_setup, privileged: true
    end
  end

  SLAVES_COUNT.times do |i|
    index = i + 2
    ip_ind = i + 3
    raise if ip_ind > 254
    config.vm.define "n#{index}" do |config|
      config.vm.host_name = "n#{index}"
      # wait 10 seconds for the first corosync node
      corosync_setup = shell_script("/vagrant/vagrant_script/conf_corosync.sh", ["#{IP24NET}.#{ip_ind}", 10])
      if provider == :docker
        config.vm.provider :docker do |d, override|
          d.name = "n#{index}"
          d.create_args = ["-i", "-t", "--privileged", "--ip=#{IP24NET}.#{ip_ind}", "--net=#{DOCKER_NET}"]
        end
        config.trigger.after :up do
          docker_exec("n#{index}","#{hosts_setup}")
          docker_exec("n#{index}","#{corosync_setup}")
          docker_exec("n#{index}","#{rabbit_ocf_setup}")
        end
      else
        config.vm.network :private_network, ip: "#{IP24NET}.#{ip_ind}", :mode => 'nat'
        config.vm.provision "shell", run: "always", inline: hosts_setup, privileged: true
        config.vm.provision "shell", run: "always", inline: corosync_setup, privileged: true
        config.vm.provision "shell", run: "always", inline: rabbit_ocf_setup, privileged: true
      end
    end
  end
end

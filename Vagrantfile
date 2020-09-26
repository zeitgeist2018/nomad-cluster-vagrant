# -*- mode: ruby -*-
# vi: set ft=ruby :

SERVERS=3
SUBNET="172.16.1.10"

Vagrant.configure(2) do |config|
  config.vm.box = "bento/ubuntu-16.04" # 16.04 LTS
#   config.vm.box = "ubuntu/bionic64" # 18.04 LTS
  config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
  end

  (1..SERVERS).each do |i|
    config.vm.define "nomad-node-#{i}" do |n|
      n.vm.provision "shell", path: "node-install.sh"
      if i == 1
        n.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true
      end
      n.vm.hostname = "nomad-node-#{i}"
      n.vm.network "private_network", ip: "#{SUBNET}#{i}"
    end
  end
end
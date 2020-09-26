# -*- mode: ruby -*-
# vi: set ft=ruby :

SERVER_COUNT=3
SUBNET="192.168.1.20"
SERVERS = []
(1..SERVER_COUNT).each do |i|
    SERVERS << {
        "ip" => "#{SUBNET}#{i}",
        "number" => i,
        "name" => "nomad-node-#{i}"
    }
end
SERVERS_IPS = SERVERS.map{ |server| server["ip"]}

Vagrant.configure(2) do |config|
  config.vm.box = "bento/ubuntu-16.04" # 16.04 LTS
#   config.vm.box = "ubuntu/bionic64" # 18.04 LTS
  config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
  end

  SERVERS.each do |server|
    config.vm.define server["name"] do |n|
      n.vm.provision "shell", path: "node-install.sh", :args => [server["number"], server["name"], server["ip"], SERVERS_IPS.join(","), SERVERS_IPS.length()]
      if server["number"] == 1
        n.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true
      end
      n.vm.network :public_network, ip: server["ip"]
      n.vm.hostname = server["name"]
    end
  end
end
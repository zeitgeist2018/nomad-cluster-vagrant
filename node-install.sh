#!/bin/bash

# Prepare env variables
export NODE_NUMBER="$1" && echo "NODE_NUMBER=$NODE_NUMBER"
export HOST="$2" && echo "HOST=$HOST"
export NODE_NAME="$2" && echo "NODE_NAME=$NODE_NAME"
export NODE_IP="$3" && echo "NODE_IP=$NODE_IP"
export SERVERS_IPS="$4" && echo "SERVERS_IPS=$SERVERS_IPS"
export SERVER_COUNT="$5" && echo "SERVER_COUNT=$SERVER_COUNT"


# Install basic packages
sudo apt-get update -y
sudo apt-get install unzip curl vim jq -y
# make an archive folder to move old binaries into
if [ ! -d /tmp/archive ]; then
  sudo mkdir /tmp/archive/
fi

# Install Docker
echo "Docker Install Beginning..."
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce
sudo service docker restart
sudo usermod -aG docker vagrant
sudo docker --version

# Install Nomad
NOMAD_VERSION=0.9.5
cd /tmp/
sudo curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
if [ ! -d nomad ]; then
  sudo unzip nomad.zip
fi
if [ ! -f /usr/bin/nomad ]; then
  sudo install nomad /usr/bin/nomad
fi
if [ -f /tmp/archive/nomad ]; then
  sudo rm /tmp/archive/nomad
fi
sudo mv /tmp/nomad /tmp/archive/nomad
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d
nomad version


# Install Consul
CONSUL_VERSION=1.8.4
sudo curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > consul.zip
if [ ! -d consul ]; then
  sudo unzip /tmp/consul.zip
fi
if [ ! -f /usr/bin/consul ]; then
  sudo install consul /usr/bin/consul
fi
if [ -f /tmp/archive/consul ]; then
  sudo rm /tmp/archive/consul
fi
sudo mv /tmp/consul /tmp/archive/consul
sudo mkdir -p /etc/consul.d
sudo chmod a+w /etc/consul.d


# Finish installation
for bin in cfssl cfssl-certinfo cfssljson
do
  if [ ! -f /tmp/${bin} ]; then
    curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
  fi
  if [ ! -f /usr/local/bin/${bin} ]; then
    sudo install /tmp/${bin} /usr/local/bin/${bin}
  fi
done
cat /root/.bashrc | grep  "complete -C /usr/bin/nomad nomad"
retval=$?
if [ $retval -eq 1 ]; then
  nomad -autocomplete-install
fi


# Stop dnsmasq, so port 53 is free for consul to use
sudo systemctl stop dnsmasq


# Form Consul Cluster
cat << EOF | sudo tee /etc/consul.d/consul-server-config.json
{
"data_dir": "/tmp/consul/server",
"server": true,
"bootstrap_expect": ${SERVER_COUNT},
"advertise_addr": "{{ GetInterfaceIP \`eth1\` }}",
"client_addr": "0.0.0.0",
"ui": true,
"datacenter": "spain",
"ports": { "dns": 53 },
"retry_join": ["192.168.1.201", "192.168.1.202", "192.168.1.203"]
}
EOF
sudo nohup consul agent --config-file /etc/consul.d/consul-server-config.json &>$HOME/consul.log &

# Form Nomad Cluster
cat <<EOF | sudo tee /etc/nomad.d/nomad-server-config.hcl
data_dir = "/tmp/nomad/server"
server {
  enabled          = true
  bootstrap_expect = ${SERVER_COUNT}
  job_gc_threshold = "2m"
}
datacenter = "spain"
region = "east"
advertise {
  http = "{{ GetInterfaceIP \`eth1\` }}"
  rpc  = "{{ GetInterfaceIP \`eth1\` }}"
  serf = "{{ GetInterfaceIP \`eth1\` }}"
}
plugin "raw_exec" {
  config {
    enabled = true
  }
}
client {
  enabled           = true
  network_interface = "eth1"
  servers           = ["192.168.1.201", "192.168.1.202", "192.168.1.203"]
}
EOF
sudo nohup nomad agent -config /etc/nomad.d/nomad-server-config.hcl &>$HOME/nomad.log &

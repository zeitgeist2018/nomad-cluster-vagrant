# Nomad Cluster Vagrant
This project aims to serve as an easy solution for running a HashiCorp Nomad
cluster, using vagrant.
By default, it spins up 3 VM's, one for each node, and each of them runs Nomad
and Consul.
I'm building an enhanced Nginx proxy, which will get all apps
running in the cluster, and create a virtual host for it, 
applying load balancing appropriately. The repository
is currently private, but I'll try to make it public in the near
future.
https://github.com/zeitgeist2018/intelligx

## Run it
1. Clone this repository
2. Execute `vagrant up` 
3. The IP's of the nodes are:
    * 192.168.1.201
    * 192.168.1.202
    * 192.168.1.203
3. You can access Nomad's or Consul's UI from any node, on the ports:
    * Nomad's UI: 4646
    * Consul's UI: 8500

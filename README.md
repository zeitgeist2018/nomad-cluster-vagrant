# Nomad Cluster Vagrant
This project aims to serve as an easy solution for running a HashiCorp Nomad
cluster, using vagrant.
By default, it spins up 3 VM's, one for each node, and each of them runs Nomad
and Consul.
With this setup, you can configure your machine's DNS to point to one of the VM's.
This enables full capabilities of Consul's DNS server.

## Run it
1. Clone this repository
2. Execute `vagrant up` 
3. These URL's will be ready after a few minutes:
    * Nomad's UI: http://192.168.1.201:4646/
    * Consul's UI: http://192.168.1.201:8500/
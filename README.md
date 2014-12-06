opencontrail
============

Use vagrant to install various flavours of opencontrail locally for testing.
The initial version simply follows the guidelines found in the quick start guide on http://www.opencontrail.org 
Currently working with OpenContrail 1.20.

the Vagrantfile starts with ubuntu/trusty64 cloud image (14.04), then downloads opencontrail binaries for 1.20, creates a testbed.py file for a single node install, then install and setups opencontrail on the NAT'd network of VirtualBox. 

Besides the VM contrail, there are two optional VM's, compute1 and compute2, which install enough packages to provision and manage these VM's from the main contrail node via fab commands.

Howto use it:

Clone this repository to an empty directory:

    $ mkdir temp
    $ cd temp
    $ git clone git://github.com/mwiget/opencontrail.git
    Cloning into 'opencontrail'...
    remote: Counting objects: 11, done.
    remote: Compressing objects: 100% (11/11), done.
    remote: Total 11 (delta 2), reused 4 (delta 0)
    Receiving objects: 100% (11/11), 10.44 KiB | 0 bytes/s, done.
    Resolving deltas: 100% (2/2), done.
    Checking connectivity... done.
    $

This will create the following files under temp/opencontrail:

    $ cd openstack
    $ ls
    LICENSE   README.md Vagrantfile provision.sh
    $

Bring up the virtual machine:

    $ vagrant up
    Bringing machine 'default' up with 'virtualbox' provider...
    ==> default: Importing base box 'ubuntu/trusty64'...
    ==> default: Matching MAC address for NAT networking...
    ==> default: Checking if box 'ubuntu/trusty64' is up to date...
    ==> default: Setting the name of the VM: simple-gateway-vagrant_default_1416160329884_44357
    ==> default: Clearing any previously set forwarded ports...
    ==> default: Clearing any previously set network interfaces...
    ==> default: Preparing network interfaces based on configuration...
        default: Adapter 1: nat
        default: Adapter 2: hostonly
    ==> default: Forwarding ports...
        default: 22 => 2222 (adapter 1)
    ==> default: Running 'pre-boot' VM customizations...
    ==> default: Booting VM...
    ==> default: Waiting for machine to boot. This may take a few minutes...
        default: SSH address: 127.0.0.1:2222
        default: SSH username: vagrant
        default: SSH auth method: private key
        default: Warning: Connection timeout. Retrying...
    ==> default: Machine booted and ready!
    ==> default: Checking for guest additions in VM...
    ==> default: Configuring and enabling network interfaces...
    ==> default: Mounting shared folders...
        default: /vagrant => /Users/mwiget/projects/temp/opencontrail
    ==> default: Running provisioner: shell...
        default: Running: /var/folders/8m/0w01fsfn6j79rb_5x7npp1m40000gn/T/vagrant-shell20141116-9617-wys9ae.sh
    ==> default: stdin: is not a tty
    ==> default: Fix ssh to allow password login
    ==> default: ssh stop/waiting
    ==> default: ssh start/running, process 1701
    ==> default: Installing OpenContrail ...
    ==> default: apt-get update ...
    ==> default: installing curl ...
    ==> default: Reading package lists...
    ==> default: Building dependency tree...
    . . .
    (bulk of the install messages removed)
    . . .
    ==> default: 2014-11-19 09:46:54:628479:
    ==> default: 2014-11-19 09:46:54:628595: Done.
    ==> default: 2014-11-19 09:46:54:628618: Disconnecting from 192.168.33.10... done.
    ==> default: 2014-11-19 09:46:54:701249:
    ==> default: You can access horizon web UI http://192.168.33.10/horizon
    ==> default: You can access OpenContrail web UI http://192.168.33.10:8080
    ==> default: Username password is admin/secret123
    ==> default: ssh access via root/secret
    ==> default: all done.
    ==> default: ***************************************************
    ==> default: *   PLEASE RELOAD THIS VAGRANT BOX BEFORE USE     *
    ==> default: ***************************************************

From here, please reboot the virtual machine in order for the vrouter kernel module to be loaded and configured correctly:

    $ vagrant reload
    ==> default: Attempting graceful shutdown of VM...
    ==> default: Checking if box 'ubuntu/trusty64' is up to date...
    ==> default: Clearing any previously set forwarded ports...
    ==> default: Clearing any previously set network interfaces...
    ==> default: Preparing network interfaces based on configuration...
        default: Adapter 1: nat
        default: Adapter 2: hostonly
    ==> default: Forwarding ports...
        default: 22 => 2222 (adapter 1)
    ==> default: Running 'pre-boot' VM customizations...
    ==> default: Booting VM...
    ==> default: Waiting for machine to boot. This may take a few minutes...
        default: SSH address: 127.0.0.1:2222
        default: SSH username: vagrant
        default: SSH auth method: private key
        default: Warning: Connection timeout. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
        default: Warning: Remote connection disconnect. Retrying...
    ==> default: Machine booted and ready!
    ==> default: Checking for guest additions in VM...
    ==> default: Configuring and enabling network interfaces...
    ==> default: Mounting shared folders...
        default: /vagrant => /Users/mwiget/projects/opencontrail
    ==> default: Machine already provisioned. Run `vagrant provision` or use the `--provision`
    ==> default: to force provisioning. Provisioners marked to run always will still run.
    $
    
Log into contrail via ssh and check that all the services are running correctly. This can take a few minutes to complete:
    
    $ vagrant ssh
    Welcome to Ubuntu 14.04.1 LTS (GNU/Linux 3.13.0-39-generic x86_64)
    
     * Documentation:  https://help.ubuntu.com/
    
      System information as of Sat Nov 22 16:21:22 UTC 2014
    
      System load:  0.45              Processes:             134
      Usage of /:   6.3% of 39.34GB   Users logged in:       0
      Memory usage: 3%                IP address for eth0:   10.0.2.15
      Swap usage:   0%                IP address for vhost0: 192.168.33.10
    
      Graph this data and manage this system at:
        https://landscape.canonical.com/
    
      Get cloud support with Ubuntu Advantage Cloud Guest:
        http://www.ubuntu.com/business/services/cloud
    
    
    vagrant@vagrant-ubuntu-trusty-64:~$ contrail-status
    == Contrail vRouter ==
    supervisor-vrouter:           active
    contrail-vrouter-agent        active
    contrail-vrouter-nodemgr      active
    
    == Contrail Control ==
    supervisor-control:           active
    contrail-control              active
    contrail-control-nodemgr      active
    contrail-dns                  active
    contrail-named                active
    
    == Contrail Analytics ==
    supervisor-analytics:         active
    contrail-analytics-api        active
    contrail-analytics-nodemgr    active
    contrail-collector            active
    contrail-query-engine         active
    
    == Contrail Config ==
    supervisor-config:            active
    contrail-api:0                active
    contrail-config-nodemgr       active
    contrail-discovery:0          active
    contrail-schema               active
    contrail-svc-monitor          active
    ifmap                         active
    
    == Contrail Web UI ==
    supervisor-webui:             active
    contrail-webui                active
    contrail-webui-middleware     active
    redis-webui                   active
    
    == Contrail Database ==
    supervisord-contrail-database:active
    contrail-database             active
    contrail-database-nodemgr     active
    
    == Contrail Support Services ==
    supervisor-support-service:   active
    rabbitmq-server               active

Adding compute1 node
--------------------

Bring up compute1 VM via vagrant:

    $ vagrant up compute1
    
The IP address is hard coded in Vagrantfile in environment variable private_net_compute1_ip (192.168.33.11).
Log into contrail and modify testbed.py according to the following patch (basically defining host2, setting root password and adding it as compute node):

    --- testbed.py.orig	2014-12-03 12:50:44.713138163 +0000
    +++ testbed.py	2014-12-03 12:51:18.369957011 +0000
    @@ -1,6 +1,7 @@
     from fabric.api import env
     #Management ip addresses of hosts in the cluster
     host1 = 'root@192.168.33.10'
    +host2 = 'root@192.168.33.11'
    
     #External routers if any
     #for eg.
    @@ -15,11 +16,11 @@
    
     #Role definition of the hosts.
     env.roledefs = {
    -    'all': [host1],
    +    'all': [host1, host2],
         'cfgm': [host1],
         'openstack': [host1],
         'control': [host1],
    -    'compute': [host1],
    +    'compute': [host1, host2],
         'collector': [host1],
         'webui': [host1],
         'database': [host1],
    @@ -40,6 +41,7 @@
     #Passwords of each host
     env.passwords = {
         host1: 'secret',
    +    host2: 'secret',
    
         host_build: 'secret',
     }
    @@ -47,6 +49,7 @@
     #For reimage purpose
     env.ostypes = {
         host1:'ubuntu',
    +    host2:'ubuntu',
     }
    
     #OPTIONAL ANALYTICS CONFIGURATION
     

Then execute the following fab command as root:

    cd /opt/contrail/utils
    fab add_vrouter_node:root@192.168.33.11


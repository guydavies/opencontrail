opencontrail
============

Use vagrant to install various flavours of opencontrail locally for testing.
The initial version simply follows the guidelines found in the quick start guide on http://www.opencontrail.org 
Currently working with OpenContrail 1.20.

the Vagrantfile starts with ubuntu/trusty64 cloud image (14.04), then downloads opencontrail binaries for 1.20, creates a testbed.py file for a single node install, then install and setups opencontrail on the NAT'd network of VirtualBox. 

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
    ==> default: all done.

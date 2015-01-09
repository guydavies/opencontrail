# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.
  # Every Vagrant virtual environment requires a box to build off of.
  #
  
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "vmware_fusion" do |v, override|
      override.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vmwarefusion.box"
  end

  private_net_contrail_ip = "192.168.100.10"
  private_net_compute1_ip = "192.168.100.11"
  private_net_compute2_ip = "192.168.100.12"

  # single node Contrail with openstack Node
  #
  config.vm.define "contrail", primary: true do |contrail|

    contrail.vm.provider "virtualbox" do |v|
      v.memory = 8096
      v.cpus = 2
    end 
    contrail.vm.provider "vmware_fusion" do |vf|
        vf.vmx["numvcpus"] = "2"
        vf.vmx["memsize"] = "8096"
    end

    # argument is used to set the VM's hostname
    #

    contrail.vm.provision "shell", path: "provision.sh", args: "contrail #{private_net_contrail_ip}"

    # Create a private network, which allows host-only access to the machine
    # using a specific IP. 
    #
    contrail.vm.network "private_network", ip: "#{private_net_contrail_ip}", auto_config: false

  end

  #
  # Prepare another VM to be added via fab commands from the primary contrail node
  # as compute node.
  #
  config.vm.define "compute1", autostart:false  do |compute|
    compute.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 1
    end
    compute.vm.provider "vmware_fusion" do |vf|
        vf.vmx["numvcpus"] = "1"
        vf.vmx["memsize"] = "4096"
    end
    compute.vm.provision "shell", path: "provision-compute.sh", args: "compute1 #{private_net_compute1_ip}"
    compute.vm.network "private_network", ip: "#{private_net_compute1_ip}", auto_config: false
  end

  #
  # Prepare another VM to be added via fab commands from the primary contrail node
  # as compute node.
  #
  config.vm.define "compute2", autostart:false do |compute|
    compute.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 1
    end
    compute.vm.provider "vmware_fusion" do |vf|
        vf.vmx["numvcpus"] = "1"
        vf.vmx["memsize"] = "4096"
    end
    compute.vm.provision "shell", path: "provision-compute.sh", args: "compute2 #{private_net_compute2_ip}"
    compute.vm.network "private_network", ip:  "#{private_net_compute2_ip}", auto_config: false
  end

end

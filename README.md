opencontrail
============

Use vagrant to install various flavours of opencontrail locally for testing.
The initial version simply follows the guidelines found in the quick start guide on http://www.opencontrail.org 
Currently working with OpenContrail 1.20.

the Vagrantfile starts with ubuntu/trusty64 cloud image (14.04), then downloads opencontrail binaries for 1.20, creates a testbed.py file for a single node install, then install and setups opencontrail on the NAT'd network of VirtualBox. 



#!/usr/bin/env bash

HOSTNAME=$1
IPADDR=$2

echo "Fix ssh to allow password login"
echo "root:secret"|chpasswd
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# Disable LANG_ALL to avoid warnings when logging in from OSX
sed -i 's/^AcceptEnv LANG LC_*/#AcceptEnv LANG LC_*/' /etc/ssh/sshd_config

service ssh restart

echo "Setting hostname to $HOSTNAME"
hostname $HOSTNAME
cat <<EOF > /etc/hostname
$HOSTNAME
EOF

/sbin/ifconfig eth1 $IPADDR
cat <<EOF >> /etc/hosts
$IPADDR $HOSTNAME
EOF
hostname $HOSTNAME

echo "Prepare OpenContrail compute node ..."
echo "apt-get update ..."
apt-get update >/dev/null 2>&1
echo "installing curl ..."
apt-get install -y curl 
echo "Getting opencontrail packages ..."
curl -L http://www.opencontrail.org/ubuntu-repo/repo_key | sudo apt-key add -
curl http://www.opencontrail.org/ubuntu-repo/add-apt-and-update | sudo OPENSTACK=icehouse CONTRAIL=r200 DISTRO=ubuntu1404 sh

apt-get install -y dpkg-dev contrail-setup contrail-fabric-utils
pip install fabric==1.7.0

echo "install nodejs ..."
apt-get install nodejs=0.8.15-1contrail1

# Grab linux headers used by linux distro, so vrouter.ko can be built
# for localhost
apt-get install -y linux-headers-$(uname -r)

echo "***************************************************************************"
echo "*   Add this host now to the testbed.py found on the contrail vagrant box"
echo "*   at /opt/contrail/utils/fabfile/testbeds/testbed.py                    "
echo "*   as role all and compute (see README.md) and execute the following     "
echo "*   fab commands in sequentual order on the contrail node:                "
echo "*   cd /opt/contrail/utils                                                " 
echo "*   fab install_vrouter:root@$IPADDR                                      " 
echo "*   fab setup_vrouter:root@$IPADDR                                        " 
echo "*   fab add_vrouter_node:root@$IPADDR                                     " 
echo "*                                                                         " 
echo "*   The node $IPADDR will reboot automatically                             " 
echo "***************************************************************************"


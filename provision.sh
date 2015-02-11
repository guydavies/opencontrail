#!/bin/bash
##!/usr/bin/env bash

HOSTNAME=$1
IPADDR=$2

echo "Fix ssh to allow password login"
ROOTPWD="secret"
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

echo "apt-get update ..."
apt-get update >/dev/null 2>&1
echo "installing curl ..."
apt-get install -y curl 
echo "Getting opencontrail packages ..."
curl -L http://www.opencontrail.org/ubuntu-repo/repo_key | sudo apt-key add -
curl http://www.opencontrail.org/ubuntu-repo/add-apt-and-update | sudo OPENSTACK=icehouse CONTRAIL=r200 DISTRO=ubuntu1404 sh

apt-get install -y dpkg-dev contrail-setup contrail-fabric-utils;
pip install fabric==1.7.0;
sed -i -e 's/def create_install_repo_node\(.*\):/def create_install_repo_node\1:\n    return\n/' /opt/contrail/utils/fabfile/tasks/install.py

echo "Creating testbed.py ..."
MYIP=`ifconfig eth1 | awk '/inet /{print $2}' | cut -f2 -d':'`
cd /opt/contrail/utils/fabfile/testbeds/
cp testbed_singlebox_example.py testbed.py
sed -i "s/1.1.1.1/$MYIP/" testbed.py

echo "install nodejs ..."
apt-get install nodejs=0.8.15-1contrail1

# Grab linux headers used by linux distro, so vrouter.ko can be built
# for localhost
apt-get install -y linux-headers-$(uname -r)

echo "install the packages and provision the (single node) cluster."

# "hardcode" the response due to issues with run() executed over non-interactve ssh session
sed -i 's/ast.literal_eval(run(linux_distro))/("Ubuntu", "14.04", "trusty")/' /opt/contrail/utils/fabfile/utils/fabos.py

echo "fab install_contrail ..."
cd /opt/contrail/utils
fab install_contrail

echo "Enabling SSLv3"
sed -i 's/^jdk.tls.disabledAlgorithms=SSLv3/#jdk.tls.disabledAlgorithms=SSLv3/' /etc/java-7-openjdk/security/java.security
# no need to downgrade package. Seems enough to just re-enable SSLv3 with above sed command.
#apt-get -y install openjdk-7-jre-headless:amd64=7u71-2.5.3-0ubuntu0.14.04.1

echo "fab setup_all ..."
fab setup_all:reboot='False'

echo "You can access horizon web UI http://$MYIP/horizon"
echo "You can access OpenContrail web UI http://$MYIP:8080"
echo "Username password is admin/secret123"
echo "ssh access via root/$ROOTPWD"

echo "all done."

echo "***************************************************"
echo "*   PLEASE RELOAD THIS VAGRANT BOX BEFORE USE     *"
echo "***************************************************"


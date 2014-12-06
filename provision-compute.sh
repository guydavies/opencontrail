#!/usr/bin/env bash

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

echo "Prepare OpenContrail compute node ..."
echo "apt-get update ..."
apt-get update >/dev/null 2>&1
echo "installing curl ..."
apt-get install -y curl 
echo "Getting opencontrail packages ..."
curl -L http://www.opencontrail.org/ubuntu-repo/repo_key | sudo apt-key add -
curl http://www.opencontrail.org/ubuntu-repo/add-apt-and-update | sudo OPENSTACK=icehouse CONTRAIL=r120 DISTRO=ubuntu1404 sh
echo "running apt-get update again to fix redundant entries"
apt-get update >/dev/null 2>&1
echo "install dpkg-dev contrail-setup ..."
#echo "install dpkg-dev contrail-setup contrail-fabric-utils ..."

# to avoid warnings about an invalid locale.
locale-gen UTF-8

eval `ssh-agent`

USER=${USER:-root}
PUBKEY_FILE=${PUBKEY_FILE:-${PWD}/testbed-key}
ECHO=${ECHO:-}

if [ -f ${PUBKEY_FILE} ]; then
  echo "Found testbed public key ${PUBKEY_FILE}"
  ${ECHO} ssh-add ${PUBKEY_FILE}
else
  echo "No testbed public key ${PUBKEY_FILE}, generating..."
  ${ECHO} ssh-keygen -t rsa -f ${PUBKEY_FILE} -N ""
fi

#apt-get install -y dpkg-dev contrail-setup 
apt-get install -y dpkg-dev contrail-setup contrail-fabric-utils
echo "installing fabric ..."
pip install fabric==1.7.0

echo "install nodejs ..."
apt-get install nodejs=0.8.15-1contrail1

# Grab linux headers used by linux distro, so vrouter.ko can be built
# for localhost
apt-get install -y linux-headers-$(uname -r)


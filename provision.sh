#!/usr/bin/env bash

echo "Fix ssh to allow password login"
ROOTPWD="secret"
echo "root:secret"|chpasswd
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
service ssh restart

echo "Installing OpenContrail ..."
echo "apt-get update ..."
apt-get update >/dev/null 2>&1
echo "installing curl ..."
apt-get install -y curl 
echo "Getting opencontrail packages ..."
curl -L http://www.opencontrail.org/ubuntu-repo/repo_key | sudo apt-key add -
curl –L http://www.opencontrail.org/ubuntu-repo/add-apt-and-update | sudo OPENSTACK=icehouse CONTRAIL=r120 DISTRO=ubuntu1404 sh
echo "running apt-get update again to fix redundant entries"
apt-get update >/dev/null 2>&1
echo "install dpkg-dev contrail-setup contrail-fabric-utils ..."

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

apt-get install -y dpkg-dev contrail-setup contrail-fabric-utils
echo "installing fabric ..."
pip install fabric==1.7.0
ssh-copy-id -i ${PUBKEY_FILE} ${USER}@127.0.0.1
sed -i -e 's/def create_install_repo_node\(.*\):/def create_install_repo_node\1:\n    return\n/' /opt/contrail/utils/fabfile/tasks/install.py
sed -i -e "s/if '1.04' in rls:/if rls and '1.04' in rls:/" /opt/contrail/utils/fabfile/tasks/provision.py
sed -i -e 's/Xss220k/Xss300k/' /opt/contrail/contrail_installer/contrail_setup_utils/setup.py

# Disable LANG_ALL to avoid warnings when logging in from OSX
sed -i 's/^AcceptEnv LANG LC_*/#AcceptEnv LANG LC_*/' /etc/ssh/sshd_config

# set ssh key pointer in example testbeds
${ECHO} echo "env.key_filename='${PUBKEY_FILE}'" >> /opt/contrail/utils/fabfile/testbeds/testbed_singlebox_example.py
${ECHO} echo "env.key_filename='${PUBKEY_FILE}'" >> /opt/contrail/utils/fabfile/testbeds/testbed_multibox_example.py


echo "Creating testbed.py ..."
MYIP=`ifconfig eth1 | awk '/inet /{print $2}' | cut -f2 -d':'`
cd /opt/contrail/utils/fabfile/testbeds/

cat <<EOF >testbed.py
from fabric.api import env
#Management ip addresses of hosts in the cluster
host1 = 'root@$MYIP'

#External routers if any
#for eg.
#ext_routers = [('mx1', '10.204.216.253')]
ext_routers = []

#Autonomous system number
router_asn = 64512

#Host from which the fab commands are triggered to install and provision
host_build = 'root@$MYIP'

#Role definition of the hosts.
env.roledefs = {
    'all': [host1],
    'cfgm': [host1],
    'openstack': [host1],
    'control': [host1],
    'compute': [host1],
    'collector': [host1],
    'webui': [host1],
    'database': [host1],
    'build': [host_build],
    'storage-master': [host1],
    'storage-compute': [host1],
}

#Openstack admin password
env.openstack_admin_password = 'secret123'

#Hostnames
env.hostnames = {
    'all': ['a0s1']
}

env.password = '$ROOTPWD'
#Passwords of each host
env.passwords = {
    host1: '$ROOTPWD',

    host_build: '$ROOTPWD',
}

#For reimage purpose
env.ostypes = {
    host1:'ubuntu',
}

#OPTIONAL ANALYTICS CONFIGURATION
#================================
# database_dir is the directory where cassandra data is stored
#
# If it is not passed, we will use cassandra's default
# /var/lib/cassandra/data
#
#database_dir = '<separate-partition>/cassandra'
#
# analytics_data_dir is the directory where cassandra data for analytics
# is stored. This is used to seperate cassandra's main data storage [internal
# use and config data] with analytics data. That way critical cassandra's
# system data and config data are not overrun by analytis data
#
# If it is not passed, we will use cassandra's default
# /var/lib/cassandra/data
#
#analytics_data_dir = '<separate-partition>/analytics_data'
#
# ssd_data_dir is the directory where cassandra can store fast retrievable
# temporary files (commit_logs). Giving cassandra an ssd disk for this
# purpose improves cassandra performance
#
# If it is not passed, we will use cassandra's default
# /var/lib/cassandra/commit_logs
#
#ssd_data_dir = '<seperate-partition>/commit_logs_data'

#OPTIONAL BONDING CONFIGURATION
#==============================
#Inferface Bonding
#bond= {
#    host1 : { 'name': 'bond0', 'member': ['p2p0p0','p2p0p1','p2p0p2','p2p0p3'], 'mode': '802.3ad', 'xmit_hash_policy': 'layer3+4' },
#}

#OPTIONAL SEPARATION OF MANAGEMENT AND CONTROL + DATA and OPTIONAL VLAN INFORMATION
#==================================================================================
#control_data = {
#    host1 : { 'ip': '192.168.10.1/24', 'gw' : '192.168.10.254', 'device': 'bond0', 'vlan': '224' },
#}

#OPTIONAL STATIC ROUTE CONFIGURATION
#===================================
#static_route  = {
#    host1 : [{ 'ip': '10.1.1.0', 'netmask' : '255.255.255.0', 'gw':'192.168.10.254', 'intf': 'bond0' },
#             { 'ip': '10.1.2.0', 'netmask' : '255.255.255.0', 'gw':'192.168.10.254', 'intf': 'bond0' }],
#}

#storage compute disk config
#storage_node_config = {
#    host1 : { 'disks' : ['sdc', 'sdd'] },
#}

#live migration config
#live_migration = True


#To disable installing contrail interface rename package
#env.interface_rename = False

#In environments where keystone is deployed outside of Contrail provisioning
#scripts , you can use the below options
#
# Note :
# "insecure" is applicable only when protocol is https
# The entries in env.keystone overrides the below options which used
# to be supported earlier :
#  service_token
#  keystone_ip
#  keystone_admin_user
#  keystone_admin_password
#  region_name
#
#env.keystone = {
#    'keystone_ip'   : 'x.y.z.a',
#    'auth_protocol' : 'http',                  #Default is http
#    'auth_port'     : '35357',                 #Default is 35357
#    'admin_token'   : '33c57636fbc2c5552fd2',  #admin_token in keystone.conf
#    'admin_user'    : 'admin',                 #Default is admin
#    'admin_password': 'contrail123',           #Default is contrail123
#    'service_tenant': 'service',               #Default is service
#    'admin_tenant'  : 'admin',                 #Default is admin
#    'region_name'   : 'RegionOne',             #Default is RegionOne
#    'insecure'      : 'True',                  #Default = False
#    'manage_neutron': 'no',                    #Default = 'yes' , Does configure neutron user/role in keystone required.
#}
#

# In High Availability setups.
#env.ha = {
#    'internal_vip'   : '$MYIP',               #Internal Virtual IP of the HA setup.
#    'external_vip'   : '2.2.2.2',               #External Virtual IP of the HA setup.
#    'nfs_server'      : '3.3.3.3',               #IP address of the NFS Server which will be mounted to /var/lib/glance/images of openstack Node, Defaults to env.roledefs['compute'][0]
#    'nfs_glance_path' : '/var/tmp/images/',      #NFS Server path to save images, Defaults to /var/tmp/glance-images/
#}

# In environments where openstack services are deployed independently
# from contrail, you can use the below options
# service_token : Common service token for for all services like nova,
#                 neutron, glance, cinder etc
# amqp_host     : IP of AMQP Server to be used in openstack
# manage_amqp   : Default = 'no', if set to 'yes' provision's amqp in openstack nodes and
#                 openstack services uses the amqp in openstack nodes instead of config nodes.
#                 amqp_host is neglected if manage_amqp is set
#
#env.openstack = {
#    'service_token' : '33c57636fbc2c5552fd2', #Common service token for for all openstack services
#    'amqp_host' : '10.204.217.19',            #IP of AMQP Server to be used in openstack
#    'manage_amqp' : 'yes',                    #Default no, Manage seperate AMQP for openstack services in openstack nodes.
#}

# Neutron specific configuration
#env.neutron = {
#   'protocol': 'http', # Default is http
#}

#To enable multi-tenancy feature
#multi_tenancy = True

#To enable haproxy feature
#haproxy = True

#To Enable prallel execution of task in multiple nodes
#do_parallel = True

# To configure the encapsulation priority. Default: MPLSoGRE
#env.encap_priority =  "'MPLSoUDP','MPLSoGRE','VXLAN'"

# Optional proxy settings.
# env.http_proxy = os.environ.get('http_proxy')

#To enable LBaaS feature
# Default Value: False
#env.enable_lbaas = True

#OPTIONAL REMOTE SYSLOG CONFIGURATION
#===================================
#For R1.10 this needs to be specified to enable rsyslog.
#For Later releases this would be enabled as part of provisioning,
#with following default values.
#
#port = 19876
#protocol = tcp
#collector = dynamic i.e. rsyslog clients will connect to servers in a round
#                         robin fasion. For static collector all clients will
#                         connect to a single collector. static - is a test
#                         only option.
#status = enable
#
#env.rsyslog_params = {'port':19876, 'proto':'tcp', 'collector':'dynamic', 'status':'enable'}

env.key_filename='${PUBKEY_FILE}'
EOF

echo "install nodejs ..."
apt-get install nodejs=0.8.15-1contrail1

echo "install the packages and provision the (single node) cluster."
echo "fab install_contrail ..."
cd /opt/contrail/utils
fab install_contrail
echo "fab setup_all ..."
fab setup_all:reboot='False'

echo "You can access horizon web UI http://$MYIP/horizon"
echo "You can access OpenContrail web UI http://$MYIP:8080"
echo "Username password is admin/secret123"
echo "ssh access via root/$ROOTPWD'

echo "all done."

reboot &


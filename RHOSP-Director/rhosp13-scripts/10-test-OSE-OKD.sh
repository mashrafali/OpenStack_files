#! /bin/bash

##### ALL NODES PINGABLE with hostnames and Passwordless SSH between each other
##### NTP
##### Network Manager Installed and enabled
#### "NM_CONTROLLED=yes" in Ifaces
#### "PEERDNS=yes" in Ifaces

## in another dns server node:
# yum install dnsmasq -y
# systemctl enable dnsmasq 
# systemctl start dnsmasq 
# echo "address=/apps.openshift.equinoxme.com/172.17.14.200" > /etc/dnsmasq.d/openshift
# systemctl restart dnsmasq
## Then add local DNS ip to Openshift nodes interfaces

yum upgrade -y
yum update -y
yum autoremove -y
yum install ntp wget git yum-utils net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct -y
yum install NetworkManager -y
systemctl enable ntpd
systemctl start ntpd
systemctl enable NetworkManager
systemctl start NetworkManager
# needs reboot here


yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel install ansible pyOpenSSL

cd ~
git clone https://github.com/openshift/openshift-ansible
cd openshift-ansible
git checkout release-3.11

yum install docker -y
systemctl enable docker
systemctl start docker


#SHOULD BE inserted seperate and Then grouped
#echo "master.openshift.equinoxme.com
#node.openshift.equinoxme.com" >> /etc/ansible/hosts

## /usr/share/doc/openshift-ansible-docs-3.11.43/docs/example-inventories

cat << 'EOF' > /root/inventory
[OSEv3:children]
masters
nodes
etcd

[OSEv3:vars]
ansible_ssh_user=root
openshift_deployment_type=origin
#openshift_deployment_type=openshift-enterprise
#oreg_auth_user=equinox
#oreg_auth_password=equinox
openshift_master_default_subdomain=apps.openshift.equinoxme.com
openshift_disable_check=memory_availability,disk_availability
openshift_clock_enabled=true
os_firewall_use_firewalld=True
openshift_portal_net=192.168.65.0/24
#osm_cluster_network_cidr=10.128.0.0/14
openshift_master_console_port=8443          #these two must match
openshift_master_api_port=8443              #these two must match

[masters]
master.openshift.equinoxme.com

[etcd]
master.openshift.equinoxme.com

[nodes]
master.openshift.equinoxme.com openshift_node_group_name='node-config-master-infra'
node1.openshift.equinoxme.com openshift_node_group_name='node-config-compute'
node2.openshift.equinoxme.com openshift_node_group_name='node-config-compute'
EOF

cp /etc/ansible/hosts /root/ansible-hosts.bak
cat inventory > /etc/ansible/hosts
ansible-playbook -i /root/inventory /root/openshift-ansible/playbooks/prerequisites.yml
# MAKE IT &&
ansible-playbook -i /root/inventory /root/openshift-ansible/playbooks/deploy_cluster.yml

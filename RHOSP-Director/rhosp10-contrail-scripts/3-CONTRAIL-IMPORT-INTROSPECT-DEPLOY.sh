#! /bin/bash

source /home/stack/stackrc 

for i in contrail-controller contrail-analytics contrail-database contrail-analytics-database; do
  openstack flavor create $i --ram 4096 --vcpus 1 --disk 40
  openstack flavor set --property "capabilities:boot_option"="local" --property "capabilities:profile"="${i}" ${i}
done

openstack baremetal import --json /home/stack/instackenv-CONTRAIL-NONHA.json
openstack baremetal configure boot

openstack baremetal node list
for node in `openstack baremetal node list -c UUID -f value`
do
  openstack baremetal node manage $node
done
openstack baremetal node list

openstack overcloud node introspect --all-manageable --provide

echo
echo "Installing Contrail Template Packages:"
sleep 1
sudo yum install contrail-tripleo-heat-templates -y
sudo yum install contrail-tripleo-puppet -y
sudo yum install puppet-contrail -y
#
mkdir -p ~/usr/share/openstack-puppet/modules/contrail
cp -R /usr/share/openstack-puppet/modules/contrail/* ~/usr/share/openstack-puppet/modules/contrail/
mkdir -p ~/usr/share/openstack-puppet/modules/tripleo
cp -R /usr/share/contrail-tripleo-puppet/* ~/usr/share/openstack-puppet/modules/tripleo
cd ~
tar czvf puppet-modules.tgz ~/usr/
upload-swift-artifacts -f puppet-modules.tgz
#upload-swift-artifacts -f /home/stack/tripleo-heat-templates/environments/contrail/artifacts/puppet-modules.tgz
#
cp -r /usr/share/openstack-tripleo-heat-templates/ ~/tripleo-heat-templates
cp -r /usr/share/contrail-tripleo-heat-templates/environments/* ~/tripleo-heat-templates/environments
cp -r /usr/share/contrail-tripleo-heat-templates/puppet/services/network/* ~/tripleo-heat-templates/puppet/services/network
rm -rf /home/stack/usr/ 
rm -rf /home/stack/puppet-modules.tgz
sed -i "s#'##g" ~/.tripleo/environments/deployment-artifacts.yaml  #Fixing Known Bug

openstack overcloud profiles list

echo
echo "BEFORE DEPLOY, YOU NEED TO PROVSION INTERNAL API GW TO BE REACHABLE BY NODES"
echo
#
#/home/stack/templates/stack-node-placment.sh

#sudo cp /home/stack/templates/environments/ceph-mon.yaml /usr/share/openstack-tripleo-heat-templates/puppet/services/ceph-mon.yaml

#openstack overcloud deploy --templates tripleo-heat-templates/ \
#  --roles-file tripleo-heat-templates/environments/contrail/roles_data.yaml \
#  -e tripleo-heat-templates/environments/puppet-pacemaker.yaml \
#  -e tripleo-heat-templates/environments/contrail/contrail-services.yaml \
#  -e tripleo-heat-templates/environments/contrail/network-isolation.yaml \
#  -e tripleo-heat-templates/environments/contrail/contrail-net.yaml \
#  -e tripleo-heat-templates/environments/network-management.yaml \
#  --libvirt-type qemu

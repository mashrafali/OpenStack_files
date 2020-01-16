#! /bin/bash

source /home/stack/stackrc 
openstack baremetal import --json /home/stack/instackenv-LAB.json
openstack baremetal configure boot

openstack baremetal node list
for node in `openstack baremetal node list -c UUID -f value`
do
  openstack baremetal node manage $node
done
openstack baremetal node list

openstack overcloud node introspect --all-manageable --provide
/home/stack/templates/stack-node-placment.sh

sudo cp /home/stack/templates/environments/ceph-mon.yaml /usr/share/openstack-tripleo-heat-templates/puppet/services/ceph-mon.yaml

openstack overcloud deploy --templates \
-e templates/environments/node-info.yaml \
-e templates/environments/scheduler_hints_env.yaml \
-e templates/environments/storage-environment.yaml \
-e templates/environments/time-zone.yaml \
--neutron-network-type vxlan \
--neutron-tunnel-types vxlan \
--ntp-server 172.17.14.10 \
--stack ICARUS \
--overcloud-ssh-user stack

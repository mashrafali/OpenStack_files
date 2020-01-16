#! /bin/bash

ironic node-update controller-0 replace properties/capabilities='node:controller-0,boot_option:local'
ironic node-update controller-1 replace properties/capabilities='node:controller-1,boot_option:local'
ironic node-update controller-2 replace properties/capabilities='node:controller-2,boot_option:local'
ironic node-update compute-0 replace properties/capabilities='node:compute-0,boot_option:local'
ironic node-update compute-1 replace properties/capabilities='node:compute-1,boot_option:local'
ironic node-update compute-2 replace properties/capabilities='node:compute-2,boot_option:local'
ironic node-update ceph-0 replace properties/capabilities='node:ceph-storage-0,boot_option:local'
ironic node-update ceph-1 replace properties/capabilities='node:ceph-storage-1,boot_option:local'
ironic node-update ceph-2 replace properties/capabilities='node:ceph-storage-2,boot_option:local'

sudo yum install crudini -y
cd /home/stack/
mkdir swift-data
cd swift-data
export SWIFT_PASSWORD=`sudo crudini --get /etc/ironic-inspector/inspector.conf swift password`
for node in $(ironic node-list | grep -i ceph |grep -v UUID| awk '{print $2}'); do swift -U service:ironic -K $SWIFT_PASSWORD download ironic-inspector inspector_data-$node; done
for node in $(ironic node-list | grep -i ceph |grep -v UUID| awk '{print $2}'); do echo "NODE: $node" ; cat inspector_data-$node | jq '.inventory.disks' ; echo "-----" ; done
#ironic node-update 15fc0edc-eb8d-4c7f-8dc0-a2a25d5e09e3 add properties/root_device='{"serial": "61866da04f37fc001ea4e31e121cfb45"}
ironic node-update ceph-0 add properties/root_device='{"name": "/dev/vda"}'
ironic node-update ceph-1 add properties/root_device='{"name": "/dev/vda"}'
ironic node-update ceph-2 add properties/root_device='{"name": "/dev/vda"}'

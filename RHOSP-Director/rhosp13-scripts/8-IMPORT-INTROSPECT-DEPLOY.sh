#! /bin/bash

source /home/stack/stackrc 

openstack overcloud node import instackenv-RHOSP13-HA.json
openstack baremetal node list
openstack overcloud node introspect --all-manageable --provide
openstack overcloud profiles list


echo "Controlling Node Palacment profiles.."
openstack baremetal node set controller-0 --property capabilities='node:controller-0,boot_option:local'
openstack baremetal node set controller-1 --property capabilities='node:controller-1,boot_option:local'
openstack baremetal node set controller-2 --property capabilities='node:controller-2,boot_option:local'
openstack baremetal node set compute-0 --property capabilities='node:compute-0,boot_option:local'
openstack baremetal node set compute-1 --property capabilities='node:compute-1,boot_option:local'
openstack baremetal node set compute-2 --property capabilities='node:compute-2,boot_option:local'
openstack baremetal node set ceph-0 --property capabilities='node:ceph-storage-0,boot_option:local'
openstack baremetal node set ceph-1 --property capabilities='node:ceph-storage-1,boot_option:local'
openstack baremetal node set ceph-2 --property capabilities='node:ceph-storage-2,boot_option:local'
echo
openstack overcloud profiles list

echo
echo "Setting ceph root Disks.."
openstack baremetal node set --property root_device='{"name": "/dev/vda"}' ceph-0                                        
openstack baremetal node set --property root_device='{"name": "/dev/vda"}' ceph-1 
openstack baremetal node set --property root_device='{"name": "/dev/vda"}' ceph-2
echo

echo "Rendering Jinja2 Templates.."
sleep 2
sudo /usr/share/openstack-tripleo-heat-templates/tools/process-templates.py -p /usr/share/openstack-tripleo-heat-templates/ -r roles_data.yaml -n network_data.yaml

echo
echo "Refreshing Services pre-deploy..."
sudo sed -i 's/#max_concurrent_builds=10/max_concurrent_builds=3/g' /etc/nova/nova.conf
sudo systemctl restart openstack-nova-api openstack-nova-scheduler && sleep 5
echo -en "- openstack-nova-api" ; sudo systemctl status openstack-nova-api | grep "Active:"
echo -en "- openstack-nova-scheduler" ; sudo systemctl status openstack-nova-scheduler | grep "Active:"
sudo systemctl restart mariadb && sleep 5
echo -en "- mariadb" ; sudo systemctl status mariadb | grep "Active:"
sudo systemctl restart docker-distribution && sleep 5
echo -en "- docker-distribution" ; sudo systemctl status docker-distribution | grep "Active:"
sudo systemctl restart rabbitmq-server && sleep 5
echo -en "- rabbitmq-server" ; sudo systemctl status rabbitmq-server | grep "Active:"
sudo systemctl restart httpd && sleep 5
echo -en "- httpd" ; sudo systemctl status httpd | grep "Active:"
echo

source /home/stack/stackrc
openstack overcloud deploy --templates \
  -e /home/stack/templates/node-info.yaml \
  -e /home/stack/templates/scheduler_hints_env.yaml \
  -e /home/stack/templates/overcloud_images.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
  -e /home/stack/templates/network-environment.yaml \
  -e /home/stack/templates/ips-from-pool-all.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
  -e /home/stack/templates/ceph-custom-config.yaml \
  -e /home/stack/templates/swap-sysupdate/enable-swap.yaml \
  -e /home/stack/templates/extras.yaml \
  --ntp-server 172.17.14.10 \
  --libvirt-type qemu

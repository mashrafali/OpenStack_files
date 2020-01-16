#! /bin/bash

SDNS=8.8.8.8


echo "Please run as Stack User."
echo "Did you adjust my script undercloud.conf ?"
read

echo "Installing Undercloud Packages"
sleep 2
sudo yum install python-tripleoclient -y
echo

echo "Creating undercloud config"
sleep 2
echo "[DEFAULT]
local_ip=172.17.14.10/24
local_interface=eth0
undercloud_public_vip=172.17.14.20
undercloud_admin_vip=172.17.14.21
masquerade_network=172.17.14.0/24
network_cidr=172.17.14.0/24
network_gateway=172.17.14.10
local_mtu = 1450
dhcp_start=172.17.14.30
dhcp_end=172.17.14.60
inspection_iprange=172.17.14.200,172.17.14.230
enable_ui=true
#undercloud_debug = true

[auth]
undercloud_admin_password = equiinfra" > /home/stack/undercloud.conf
echo

echo "Deploying Undercloud"
sleep 2
openstack undercloud install
sleep 1
echo "export PS1='(undercloud)[\u@\h \W]\$'" >> /home/stack/stackrc
source /home/stack/stackrc
echo

echo "Installing Undercloud Images"
sleep 2
sudo yum install rhosp-director-images rhosp-director-images-ipa -y
echo

echo "Uploading Images to undercloud Glance"
sleep 2
mkdir /home/stack/images
cd /home/stack/images
sudo cp /usr/share/rhosp-director-images/*latest* /home/stack/images/
for list in `ls /home/stack/images`
do
  tar xvf /home/stack/images/$list
done
rm -rf /home/stack/images/*.tar
#
echo
echo "Manually Adjust root for overcloud-image (2.5-Adjust-root-guestfish)"
echo "Hit Enter when done"
read
read
#
openstack overcloud image upload --image-path /home/stack/images
cd ; rm -rf /home/stack/images/
echo

echo "Adjusting Ctl-Subnet DNS"
sleep 2
for net in `openstack subnet list --c ID -f value`
do
  openstack subnet set --name ctl-plane $net
  openstack subnet set --dns-nameserver $SDNS $net
done
openstack subnet list
sleep 2
openstack subnet show ctl-plane
sleep 2
echo

echo " === Ready for next Phase [IMPORT-INTROSPECT-DEPLOY] ==="
echo

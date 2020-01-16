#! /bin/bash

SDNS=8.8.8.8

echo
echo "- Please run as Stack User."
echo "- Did you adjust my script undercloud.conf ?"
echo "- CARE FOR BRCTL INTERFACE"
read

echo "Installing Undercloud Packages"
sleep 2
sudo yum install python-tripleoclient -y
sudo yum install ceph-ansible -y
echo

echo "Creating undercloud config"
sleep 2
echo "[DEFAULT]
undercloud_hostname = director.equinoxme.com
local_ip = 172.17.14.10/24
undercloud_public_host = 172.17.14.11
undercloud_admin_host = 172.17.14.12
undercloud_ntp_servers = 172.17.14.10
overcloud_domain_name = equinoxme.com
subnets = ctlplane-subnet
local_subnet = ctlplane-subnet
local_interface = eth1
local_mtu = 1450
inspection_interface = br-ctlplane
undercloud_update_packages = true
enable_tempest = true
enable_telemetry = false
enable_ui = true
enable_validations = true
ipxe_enabled = true
scheduler_max_attempts = 30
enabled_hardware_types = ipmi,redfish,ilo,idrac,cisco-ucs-managed,irmc,staging-ovirt
enable_routed_networks = true
inspection_extras = true

[auth]
undercloud_admin_password = equiinfra

[ctlplane-subnet]
cidr = 172.17.14.0/24
dhcp_start = 172.17.14.200
dhcp_end = 172.17.14.230
inspection_iprange = 172.17.14.100,172.17.14.130
gateway = 172.17.14.1
masquerade = true" > /home/stack/undercloud.conf
echo

echo "Deploying Undercloud"
sleep 2
openstack undercloud install
echo

echo
systemctl list-unit-files | grep service | grep openstack | grep enabled
sleep 3
echo "equiinfra" | exec su -l stack
echo

echo "Installing Undercloud Images"
sleep 2
sudo yum install rhosp-director-images rhosp-director-images-ipa -y
sudo yum install libguestfs-tools -y
sudo yum install guestfish -y
echo

echo "Uploading Images to undercloud Glance"
sleep 2
source /home/stack/stackrc
mkdir /home/stack/images
cd /home/stack/images
sudo cp /usr/share/rhosp-director-images/*latest.tar /home/stack/images/
for list in `ls /home/stack/images`
do
  tar xvf /home/stack/images/$list
done
rm -rf /home/stack/images/*.tar
#
echo
echo "Adjust root for overcloud-image (please be patient...)"
echo
cd /home/stack/images
guestfish --rw -i -a "overcloud-full.qcow2"  <<'EOF'
   write /etc/motd "  >> Equinox RedHat OpenStack Image <<  "
   chmod 0644 /etc/motd
   download /etc/shadow /tmp/shadow
   ! sed 's/^root:.*/root:$1$4jYKkmYM$9ivwbt9NwdvM9VIVJx2xV.::0:99999:7:::/' /tmp/shadow > /tmp/shadow.new
   upload /tmp/shadow.new /etc/shadow
   upload /etc/hosts /etc/hosts
   upload /etc/yum.repos.d/equinox.repo /etc/yum.repos.d/equinox.repo
EOF
#
openstack overcloud image upload --image-path /home/stack/images
cd ; rm -rf /home/stack/images/
echo

echo "Adjusting Ctl-Subnet DNS"
sleep 2
openstack subnet set --dns-nameserver 1.1.1.1 --dns-nameserver 8.8.8.8 ctlplane-subnet
openstack subnet list
openstack subnet show ctlplane-subnet
sleep 2
echo
sudo systemctl list-unit-files | grep -i openstack | grep enabled
echo
echo " === Ready for next Phase [IMPORT-INTROSPECT-DEPLOY] ==="
echo

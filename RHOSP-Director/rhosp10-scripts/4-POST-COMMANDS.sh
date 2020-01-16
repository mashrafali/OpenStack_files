#! /bin/bash

ProvNetStart="172.17.14.100"
ProvNetEnd="172.17.14.150"
ProvNetGW="172.17.14.1"
ProvNetCIDR="172.17.14.0/24"
ProvNetDNS="8.8.8.8"

source /home/stack/ICARUSrc

neutron net-create --shared --provider:physical_network datacentre --provider:network_type flat provider
neutron subnet-create --name provider --allocation-pool start=$ProvNetStart,end=$ProvNetEnd --dns-nameserver $ProvNetDNS --gateway $ProvNetGW provider $ProvNetCIDR
neutron net-update provider --router:external



source /home/stack/stackrc
openstack server list -c Networks -f value | cut -d "=" -f2 > /tmp/rhos-node-list

let i=1
while read line
do
cat > /tmp/ssh-works-$i << EOF
ssh -o StrictHostKeyChecking=no heat-admin@$line '
echo -en "Changing (root|heat-admin) Passwords for : " ; hostname
echo "heat-admin:equiinfra" | sudo chpasswd
echo "root:equiinfra" | sudo chpasswd
'
EOF
chmod +x /tmp/ssh-works-$i
let i=$i+1
done < /tmp/rhos-node-list


count=$(ls -lh /tmp/ssh-works-* | wc -l)

for j in $(seq 1 $count)
do
/tmp/ssh-works-$j
sleep 1
done


sudo yum install sshpass -y
sudo cp /etc/ssh/sshd_config /tmp/ssh-config
sudo chown stack:stack /tmp/ssh-config

while read line
do
echo "Passing SSH Configs to $line:"
sshpass -p "equiinfra" scp /tmp/ssh-config heat-admin@$line:/home/heat-admin/
done < /tmp/rhos-node-list

let i=1
while read line
do
cat > /tmp/ssh-works-$i << EOF
ssh -o StrictHostKeyChecking=no heat-admin@$line '
echo -en "Updating SSH configs for : " ; hostname
sudo mkdir /etc/ssh/CONFIG-BACKUP
sudo cp /etc/ssh/sshd_config /etc/ssh/CONFIG-BACKUP/sshd_config
sudo cp /home/heat-admin/ssh-config /etc/ssh/sshd_config
sudo chown root:root /etc/ssh/sshd_config
sudo systemctl restart sshd
'
EOF

chmod +x /tmp/ssh-works-$i
let i=$i+1
done < /tmp/rhos-node-list


count=$(ls -lh /tmp/ssh-works-* | wc -l)

for j in $(seq 1 $count)
do
/tmp/ssh-works-$j
sleep 1
done

rm -rf /tmp/ssh-config
rm -rf /tmp/ssh-works-*

### Upload Images ###

#####
## openstack overcloud support report collect -o /home/stack/test-log-collection controller

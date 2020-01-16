#! /bin/bash

ProvNetStart="192.168.65.150"
ProvNetEnd="192.168.65.180"
ProvNetGW="192.168.65.1"
ProvNetCIDR="192.168.65.0/24"
ProvNetDNS="8.8.8.8"

source /home/stack/overcloudrc

neutron net-create --shared --provider:physical_network datacentre --provider:network_type flat provider
neutron subnet-create --name provider --allocation-pool start=$ProvNetStart,end=$ProvNetEnd --dns-nameserver $ProvNetDNS --gateway $ProvNetGW provider $ProvNetCIDR
neutron net-update provider --router:external

echo
echo "Adjusting Director Hosts file..."
source /home/stack/stackrc
cat /dev/null > /tmp/hosting-edit
cat /dev/null > /tmp/hosting-edit-ips
cat /dev/null > /tmp/hosting-edit-name
cat /dev/null > /tmp/hosting-edit-result
openstack server list -c Name -c Networks -f value > /tmp/hosting-edit
while read server
do
  echo $server | cut -d "=" -f2                    >> /tmp/hosting-edit-ips
  echo $server | cut -d "=" -f1 | awk '{print $1}' >> /tmp/hosting-edit-name
done < /tmp/hosting-edit

list=$(cat /tmp/hosting-edit | wc -l)
for i in `seq 1 $list`
do
  SERVERIP=$(sed "${i}q;d" /tmp/hosting-edit-ips)
  SERVERNAME=$(sed "${i}q;d" /tmp/hosting-edit-name)
  SERVERRESOLVE=$(sed "${i}q;d" /tmp/hosting-edit-name | cut -d "-" -f2,3)
  echo "$SERVERIP    $SERVERNAME    $SERVERRESOLVE" >> /tmp/hosting-edit-result
done
sudo chmod 666 /etc/hosts
cat /tmp/hosting-edit-result | sort -rk3 >> /etc/hosts
sudo chmod 644 /etc/hosts
echo

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

echo
echo "Building Nodes Command Tools..."
echo
mkdir -p /home/stack/COMMAND-NODES/

cat << 'EOF' > /home/stack/COMMAND-NODES/command-controller
#! /bin/bash

command=$1
k=$(cat /etc/hosts | grep controller | wc -l)
let k=$k-1
if [ -z "$1" ]
then
  echo
  echo ' - Use command like this {./command "command to exe" }'
  echo
  kill $$
fi
echo
echo "Executing command as heat-admin user..."
echo
for i in `seq 0 $k`
do
  echo "###### controller-$i : "
  ssh -o StrictHostKeyChecking=no heat-admin@controller-$i "$command"
  echo
done
EOF

cp /home/stack/COMMAND-NODES/command-controller /home/stack/COMMAND-NODES/command-compute
cp /home/stack/COMMAND-NODES/command-controller /home/stack/COMMAND-NODES/command-ceph
sed -i 's#controller#compute#g' /home/stack/COMMAND-NODES/command-compute
sed -i 's#controller#cephstorage#g' /home/stack/COMMAND-NODES/command-ceph
chmod +x /home/stack/COMMAND-NODES/*
echo

rm -rf /tmp/ssh-config
rm -rf /tmp/ssh-works-*
rm -rf /tmp/hosting-edit*
rm -rf /tmp/rhos-node-list

### Upload Images ###

#####
## openstack overcloud support report collect -o /home/stack/test-log-collection controller

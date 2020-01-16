#! /bin/bash

#virsh dumpxml ceph-0 > ceph-0.xml
#virsh define ceph-0.xml
#virsh edit ceph-0

KVMHOST=172.17.14.1
ControllerCount=1
ComputeCount=1
CephCount=3

cat <<'EOF' > /etc/rc.d/rc.local
#!/bin/bash

touch /var/lock/subsys/local

EOF

chmod +x /etc/rc.d/rc.local
chmod a+rw /var/lib/libvirt/images/
touch /tmp/instackenv-RHOSP13-HA.json
cat /dev/null > /tmp/instackenv-RHOSP13-HA.json
yum install python-virtualbmc -y
cat << EOF > /tmp/instackenv-RHOSP13-HA.json
{
  "nodes": [
EOF

let CON=$ControllerCount-1
let COM=$ComputeCount-1
let CEP=$CephCount-1
################################################################# Director
#virt-install \
#--name Director-Contrail \
#--description "Director Stack Juniper Contrail" \
#--os-type=Linux --os-variant=rhel7.4 \
#--ram=32000 \
#--vcpus=8 \
#--disk size=120,bus=virtio \
#--network network=br0,model=virtio,portgroup=overcloud,mac=00:11:11:11:11:11 \
#--network bridge=pxe-boot,model=virtio \
#--pxe \
#--noautoconsole \
#--serial pty --console pty,target_type=virtio \
#--virt-type kvm \

################################################################# CONTROLLERs
for i in `seq 0 $CON`
do
virt-install \
--name controller-$i \
--description "Director Stack controller-$i" \
--os-type=Linux --os-variant=rhel7.5 \
--ram=32768 \
--vcpus=8 \
--disk size=60,bus=virtio \
--network bridge=man-prov,model=virtio,mac=00:11:22:33:00:$i$i \
--network network=br0,model=virtio,portgroup=overcloud \
--network network=br0,model=virtio,portgroup=overcloud \
--network bridge=external-Mang,model=virtio \
--network type=direct,source=enp8s0.65,source_mode=bridge,model=virtio,portgroup=overcloud \
--pxe \
--noautoconsole \
--serial pty --console pty,target_type=virtio \
--virt-type kvm \

cat << EOF >> /tmp/instackenv-RHOSP13-HA.json
    {
      "mac": [
        "00:11:22:33:00:$i$i"
      ],
      "pm_type": "ipmi",
      "pm_user": "admin",
      "pm_password": "p455w0rd!",
      "pm_addr": "$KVMHOST",
      "pm_port": "621$i",
      "name": "controller-$i",
      "cpu": "8",
      "memory": "32000",
      "disk": "55",
      "capabilities": "profile:control,boot_option:local",
      "arch": "x86_64"
    },
EOF
vbmc add controller-$i --address $KVMHOST --port 621$i --username admin --password p455w0rd! 2> /dev/null
vbmc start controller-$i 2> /dev/null
echo "/usr/bin/vbmc start controller-$i" >> /etc/rc.d/rc.local
done

################################################################# COMPUTEs
for i in `seq 0 $COM`
do
virt-install \
--name compute-$i \
--description "Director Stack compute-$i" \
--os-type=Linux --os-variant=rhel7.5 \
--ram=32768 \
--vcpus=8 \
--disk size=60,bus=virtio \
--network bridge=man-prov,model=virtio,mac=00:11:22:33:11:$i$i \
--network network=br0,model=virtio,portgroup=overcloud \
--network network=br0,model=virtio,portgroup=overcloud \
--network bridge=external-Mang,model=virtio \
--pxe \
--noautoconsole \
--serial pty --console pty,target_type=virtio \
--virt-type kvm \

cat << EOF >> /tmp/instackenv-RHOSP13-HA.json
    {
      "mac": [
        "00:11:22:33:11:$i$i"
      ],
      "pm_type": "ipmi",
      "pm_user": "admin",
      "pm_password": "p455w0rd!",
      "pm_addr": "$KVMHOST",
      "pm_port": "622$i",
      "name": "compute-$i",
      "cpu": "8",
      "memory": "32000",
      "disk": "55",
      "capabilities": "profile:compute,boot_option:local",
      "arch": "x86_64"
    },
EOF
vbmc add compute-$i --address $KVMHOST --port 622$i --username admin --password p455w0rd! 2> /dev/null
vbmc start compute-$i 2> /dev/null
echo "/usr/bin/vbmc start compute-$i" >> /etc/rc.d/rc.local
done

################################################################# CEPHs
for i in `seq 0 $CEP`
do
virt-install \
--name ceph-$i \
--description "Director Stack ceph-$i" \
--os-type=Linux --os-variant=rhel7.5 \
--ram=6144 \
--vcpus=6 \
--disk size=45,bus=virtio \
--disk size=60,bus=virtio \
--disk size=60,bus=virtio \
--disk size=60,bus=virtio \
--network bridge=man-prov,model=virtio,mac=00:11:22:33:22:$i$i \
--network network=br0,model=virtio,portgroup=overcloud \
--network network=br0,model=virtio,portgroup=overcloud \
--network bridge=external-Mang,model=virtio \
--pxe \
--noautoconsole \

cat << EOF >> /tmp/instackenv-RHOSP13-HA.json
    {
      "mac": [
        "00:11:22:33:22:$i$i"
      ],
      "pm_type": "ipmi",
      "pm_user": "admin",
      "pm_password": "p455w0rd!",
      "pm_addr": "$KVMHOST",
      "pm_port": "623$i",
      "name": "ceph-$i",
      "cpu": "6",
      "memory": "6000",
      "disk": "40",
      "capabilities": "profile:ceph-storage,boot_option:local",
      "arch": "x86_64"
    },
EOF
vbmc add ceph-$i --address $KVMHOST --port 623$i --username admin --password p455w0rd! 2> /dev/null
vbmc start ceph-$i 2> /dev/null
echo "/usr/bin/vbmc start ceph-$i" >> /etc/rc.d/rc.local
done
######################################################

cat << EOF >> /tmp/instackenv-RHOSP13-HA.json
  ]
}
EOF
sed -i '146s/.*/    }/' /tmp/instackenv-RHOSP13-HA.json

echo
virsh list --all
vbmc list 2> /dev/null

echo -en "Setting VMs MTU to support Jumbo Frames..."
sleep 2
for i in `ip a | grep -i vnet | awk {'print $2'} | cut -d ":" -f1` ; do ip link set $i mtu 9000; done
echo "[Done]"
echo

echo "Transfer Instack file to director:"
scp /tmp/instackenv-RHOSP13-HA.json stack@director:/home/stack/

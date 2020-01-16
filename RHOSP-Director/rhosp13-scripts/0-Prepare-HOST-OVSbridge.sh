#! /bin/bash

yum install libguestfs libguestfs-tools openvswitch virt-install qemu-kvm libvirt libvirt-python qemu-kvm-common qemu-kvm-tools -y
yum install yum-plugin-versionlock -y

systemctl enable libvirtd
systemctl enable openvswitch
systemctl start libvirtd
systemctl start openvswitch


cd /tmp/
cat << EOF > br0.xml
<network>
  <name>br0</name>
  <forward mode='bridge'/>
  <bridge name='br0'/>
  <mtu size="9000"/>
  <virtualport type='openvswitch'/>
  <portgroup name='overcloud'>
    <vlan trunk='yes'>
      <tag id='10'/>
      <tag id='20'/>
      <tag id='30'/>
      <tag id='40'/>
      <tag id='50'/>
      <tag id='60'/>
    </vlan>
  </portgroup>
</network>
EOF

virsh net-define br0.xml
virsh net-start br0
virsh net-autostart br0

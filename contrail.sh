## https://github.com/Juniper/contrail-tripleo-heat-templates/tree/stable/newton
## https://www.juniper.net/documentation/en_US/contrail4.1/topics/concept/deploy-rhospd10.html
## https://github.com/michaelhenkel/contrail-tripleo-howto
## https://www.youtube.com/playlist?list=PLbhb0KC-VJELz8OOhS62xjkZpFzvyTKnP

## ON KVM VISOR
yum install libguestfs libguestfs-tools openvswitch virt-install qemu-kvm libvirt libvirt-python qemu-kvm-common qemu-kvm-tools -y

yum install yum-plugin-versionlock -y
cd orange-stack/java-contrail-4.1.1/
yum downgrade java-1.8.0-openjdk-1.8.0.151-5.b12.el7_4.x86_64.rpm java-1.8.0-openjdk-headless-1.8.0.151-5.b12.el7_4.x86_64.rpm -y
yum versionlock java-1.8.0-openjdk java-1.8.0-openjdk-headless

systemctl enable libvirtd
systemctl enable openvswitch
systemctl start libvirtd
systemctl start openvswitch

ovs-vsctl add-br br0
ovs-vsctl add-br br1
#ovs-vsctl add-port br0 NIC1
#ovs-vsctl add-port br1 NIC2
useradd -G libvirt stack
echo equiinfra | passwd stack --stdin
echo "stack ALL=(root) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack
ssh-keygen -t rsa -N "" -f ~/.ssh/id_dsa
chgrp -R libvirt /var/lib/libvirt/images
chmod g+rw /var/lib/libvirt/images

echo "[libvirt Management Access]
Identity=unix-user:stack
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes" > /etc/polkit-1/localauthority/50-local.d/50-libvirt-user-stack.pkla

cd /tmp
cat << EOF > br0.xml
<network>
  <name>br0</name>
  <forward mode='bridge'/>
  <bridge name='br0'/>
  <mtu size="9000"/>
  <virtualport type='openvswitch'/>
  <portgroup name='overcloud'>
    <vlan trunk='yes'>
      <tag id='700' nativeMode='untagged'/>
      <tag id='710'/>
      <tag id='720'/>
      <tag id='730'/>
      <tag id='740'/>
      <tag id='750'/>
    </vlan>
  </portgroup>
</network>
EOF
cat << EOF > br1.xml
<network>
  <name>br1</name>
  <forward mode='bridge'/>
  <bridge name='br1'/>
  <virtualport type='openvswitch'/>
</network>
EOF

virsh net-define br0.xml
virsh net-start br0
virsh net-autostart br0
virsh net-define br1.xml
virsh net-start br1
virsh net-autostart br1

./0-CONTRAIL-KVM-CREATE-VMS
./1-CONTRAIL-Prepare-Director-ROOT.sh
./2-Prepare-Director-STACK.sh

### IN DIRECTOR AFTER INTROSPECT

yum install yum-plugin-versionlock -y
cd orange-stack/java-contrail-4.1.1/
yum downgrade java-1.8.0-openjdk-1.8.0.151-5.b12.el7_4.x86_64.rpm java-1.8.0-openjdk-headless-1.8.0.151-5.b12.el7_4.x86_64.rpm -y
yum install java-1.8.0-openjdk-1.8.0.151-5.b12.el7_4.x86_64.rpm java-1.8.0-openjdk-headless-1.8.0.151-5.b12.el7_4.x86_64.rpm -y
yum versionlock java-1.8.0-openjdk java-1.8.0-openjdk-headless


for i in contrail-controller contrail-analytics contrail-database contrail-analytics-database
do
  openstack flavor create $i --ram 4096 --vcpus 1 --disk 40
  openstack flavor set --property "capabilities:boot_option"="local" --property "capabilities:profile"="${i}" ${i}
done

sudo yum install contrail-tripleo-heat-templates -y

cp -r /usr/share/openstack-tripleo-heat-templates/ ~/tripleo-heat-templates
cp -r /usr/share/contrail-tripleo-heat-templates/environments/* ~/tripleo-heat-templates/environments
cp -r /usr/share/contrail-tripleo-heat-templates/puppet/services/network/* ~/tripleo-heat-templates/puppet/services/network


#! /bin/bash

echo "[libvirt Management Access]
Identity=unix-user:stack
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes" > /etc/polkit-1/localauthority/50-local.d/50-libvirt-user-stack.pkla

chmod a+rw /var/lib/libvirt/images/
################################################################# CONTROLLERS
for i in {0..2}
do
sleep 2
virt-install \
--name controller-$i \
--description "Director Stack controller-$i" \
--os-type=Linux --os-variant=rhel7.4 \
--ram=32768 \
--vcpus=8 \
--disk size=45,bus=virtio \
--network bridge=man-prov,model=virtio,mac=00:11:22:33:00:$i$i \
--pxe \
--noautoconsole \
--noreboot
done

################################################################# COMPUTES
for i in {0..2}
do
sleep 2
virt-install \
--name compute-$i \
--description "Director Stack compute-$i" \
--os-type=Linux --os-variant=rhel7.4 \
--ram=12000 \
--vcpus=6 \
--disk size=45,bus=virtio \
--network bridge=man-prov,model=virtio,mac=00:11:22:33:11:$i$i \
--pxe \
--noautoconsole \
--noreboot
done

################################################################# CEPHs
for i in {0..2}
do
sleep 2
virt-install \
--name ceph-$i \
--description "Director Stack ceph-$i" \
--os-type=Linux --os-variant=rhel7.4 \
--ram=6144 \
--vcpus=6 \
--disk size=45,bus=virtio \
--disk size=60,bus=virtio \
--disk size=60,bus=virtio \
--disk size=60,bus=virtio \
--network bridge=man-prov,model=virtio,mac=00:11:22:33:22:$i$i \
--pxe \
--noautoconsole \
--noreboot
done

#sleep 2
#virsh destroy controller-0
#sleep 2
#virsh destroy controller-1
#sleep 2
#virsh destroy controller-2
#sleep 2 
#virsh destroy compute-0
#sleep 2 
#virsh destroy compute-1
#sleep 2 
#virsh destroy compute-2
#sleep 2 
#virsh destroy ceph-0
#sleep 2 
#virsh destroy ceph-1
#sleep 2 
#virsh destroy ceph-2

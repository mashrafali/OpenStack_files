#! /bin/bash

echo "[libvirt Management Access]
Identity=unix-user:stack
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes" > /etc/polkit-1/localauthority/50-local.d/50-libvirt-user-stack.pkla

chmod a+rw /var/lib/libvirt/images/
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
#--noreboot

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
--serial pty --console pty,target_type=virtio \
--virt-type kvm \
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
--serial pty --console pty,target_type=virtio \
--virt-type kvm \
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
--serial pty --console pty,target_type=virtio \
--virt-type kvm \
--noreboot
done

################################################################# Contrail VMS
for i in {0..2}
do
sleep 2
#################### contrail-controller
virt-install \
--name contrail-controller-$i \
--description "Director Stack contrail-controller-$i" \
--os-type=Linux --os-variant=rhel7.4 \
--ram=16000 \
--vcpus=6 \
--disk size=45,bus=virtio \
--network bridge=man-prov,model=virtio,mac=00:11:22:33:33:$i$i \
--pxe \
--noautoconsole \
--serial pty --console pty,target_type=virtio \
--virt-type kvm \
--noreboot
#################### contrail-analytics
virt-install \
--name contrail-analytics-$i \
--description "Director Stack contrail-analytics-$i" \
--os-type=Linux --os-variant=rhel7.4 \
--ram=16000 \
--vcpus=6 \
--disk size=45,bus=virtio \
--network bridge=man-prov,model=virtio,mac=00:11:22:33:44:$i$i \
--pxe \
--noautoconsole \
--serial pty --console pty,target_type=virtio \
--virt-type kvm \
--noreboot
#################### contrail-analytics-database
virt-install \
--name contrail-analytics-database-$i \
--description "Director Stack contrail-analytics-database-$i" \
--os-type=Linux --os-variant=rhel7.4 \
--ram=16000 \
--vcpus=6 \
--disk size=100,bus=virtio \
--network bridge=man-prov,model=virtio,mac=00:11:22:33:55:$i$i \
--pxe \
--noautoconsole \
--serial pty --console pty,target_type=virtio \
--virt-type kvm \
--noreboot
done

#! /bin/bash

echo "Did you modify my Script hosts config?"
read

echo "Adjusting Hosts File"
sleep 2
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
172.17.14.10  director.equinoxme.com director" > /etc/hosts
echo

echo "Adjusting Hostname"
sleep 2
echo "director.equinoxme.com" > /etc/hostname
echo

echo "Adjusting Required Repos"
sleep 2
echo "[equinox-rhel-7-server-extras-rpms]
name=Equinox rhel-7-server-extras-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-extras-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-openstack-10-optools-rpms]
name=Equinox rhel-7-server-openstack-10-optools-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-openstack-10-optools-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-openstack-10-rpms]
name=Equinox rhel-7-server-openstack-10-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-openstack-10-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-openstack-10-tools-rpms]
name=Equinox rhel-7-server-openstack-10-tools-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-openstack-10-tools-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-optional-rpms]
name=Equinox rhel-7-server-optional-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-optional-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-rhceph-2-mon-rpms]
name=Equinox rhel-7-server-rhceph-2-mon-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-rhceph-2-mon-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-rhceph-2-osd-rpms]
name=Equinox rhel-7-server-rhceph-2-osd-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-rhceph-2-osd-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-rhceph-2-tools-rpms]
name=Equinox rhel-7-server-rhceph-2-tools-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-rhceph-2-tools-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-rh-common-rpms]
name=Equinox rhel-7-server-rh-common-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-rh-common-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-rpms]
name=Equinox rhel-7-server-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-supplementary-rpms]
name=Equinox rhel-7-server-supplementary-rpms       
baseurl=file:///root/RHEL-REPO/rhel-7-server-supplementary-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-ha-for-rhel-7-server-rpms]
name=Equinox rhel-ha-for-rhel-7-server-rpms       
baseurl=file:///root/RHEL-REPO/rhel-ha-for-rhel-7-server-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rogue-pkgs]
name=Equinox rogue-pkgs       
baseurl=file:///root/RHEL-REPO/rogue-pkgs/Packages    
enabled=1
gpgcheck=0" > /etc/yum.repos.d/equinox.repo

echo
echo "Updating System"
sleep 2
yum clean all
rm -rf /var/cache/yum
yum repolist
yum upgrade -y
yum update -y
yum autoremove -y
yum remove cloud-init -y
echo

echo "Installing Tools"
sleep 2
yum install htop pydf unzip iftop make nano tcpdump dnsutils ethtool nload nmap yum-utils net-tools wget telnet -y
echo

echo "Installing NTP"
sleep 2
yum install ntp -y
echo "driftfile /var/lib/ntp/drift
restrict default nomodify notrap nopeer noquery

restrict 127.0.0.1
restrict ::1
restrict 172.17.14.0 mask 255.255.255.0 nomodify notrap
server 127.127.1.0
fudge 127.127.1.0 stratum 10

includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
disable monitor" > /etc/ntp.conf

systemctl enable ntpd
systemctl start ntpd
sleep 2
systemctl status ntpd
echo
ntpstat
sleep 2
echo

echo "Creating Stack User"
sleep 2
adduser stack
echo "stack:equiinfra" | chpasswd
echo "stack        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/stack
chmod 0400 /etc/sudoers.d/stack
echo

echo "Root is done...rebooting"
sleep 2
reboot

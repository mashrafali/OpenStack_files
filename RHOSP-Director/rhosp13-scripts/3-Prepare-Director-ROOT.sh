#! /bin/bash

echo "Did you modify my Script hosts config?"
echo "CARE FOR NTP"
read

echo "Adjusting Hosts File"
sleep 2
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
172.17.14.10  director.equinoxme.com director
172.17.14.1   resources.equinoxme.com resources" > /etc/hosts
echo

echo "Adjusting Hostname"
sleep 2
echo "director.equinoxme.com" > /etc/hostname
echo

echo "Adjusting Required Repos"
sleep 2
echo "[equinox-rhel-7-server-extras-rpms]
name=Equinox rhel-7-server-extras-rpms
baseurl=http://resources/RHEL-REPO/rhel-7-server-extras-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-7-server-openstack-13-optools-rpms]
name=Equinox rhel-7-server-openstack-13-optools-rpms
baseurl=http://resources/RHEL-REPO/rhel-7-server-openstack-13-optools-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-7-server-openstack-13-rpms]
name=Equinox rhel-7-server-openstack-13-rpms
baseurl=http://resources/RHEL-REPO/rhel-7-server-openstack-13-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-7-server-openstack-13-tools-rpms]
name=Equinox rhel-7-server-openstack-13-tools-rpms
baseurl=http://resources/RHEL-REPO/rhel-7-server-openstack-13-tools-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-7-server-openstack-13-devtools-rpms]
name=Equinox rhel-7-server-openstack-13-devtools-rpms
baseurl=http://resources/RHEL-REPO/rhel-7-server-openstack-13-devtools-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-7-server-optional-rpms]
name=Equinox rhel-7-server-optional-rpms
baseurl=http://resources/RHEL-REPO/rhel-7-server-optional-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-7-server-rhceph-3-mon-rpms]
name=Equinox rhel-7-server-rhceph-3-mon-rpms
baseurl=http://resources/RHEL-REPO/rhel-7-server-rhceph-3-mon-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-7-server-rhceph-3-osd-rpms]
name=Equinox rhel-7-server-rhceph-3-osd-rpms       
baseurl=http://resources/RHEL-REPO/rhel-7-server-rhceph-3-osd-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-7-server-rhceph-3-tools-rpms]
name=Equinox rhel-7-server-rhceph-3-tools-rpms
baseurl=http://resources/RHEL-REPO/rhel-7-server-rhceph-3-tools-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-7-server-rh-common-rpms]
name=Equinox rhel-7-server-rh-common-rpms
baseurl=http://resources/RHEL-REPO/rhel-7-server-rh-common-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-7-server-rpms]
name=Equinox rhel-7-server-rpms       
baseurl=http://resources/RHEL-REPO/rhel-7-server-rpms/Packages    
enabled=1
gpgcheck=0

[equinox-rhel-7-server-supplementary-rpms]
name=Equinox rhel-7-server-supplementary-rpms
baseurl=http://resources/RHEL-REPO/rhel-7-server-supplementary-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rhel-ha-for-rhel-7-server-rpms]
name=Equinox rhel-ha-for-rhel-7-server-rpms
baseurl=http://resources/RHEL-REPO/rhel-ha-for-rhel-7-server-rpms/Packages
enabled=1
gpgcheck=0

[equinox-rogue-pkgs]
name=Equinox rogue-pkgs
baseurl=http://resources/RHEL-REPO/rogue-pkgs/Packages
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
chmod 666 /etc/ntp.conf
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

echo "Disabling firewall & Network Manager.."
sleep 1
systemctl stop firewalld
systemctl disable firewalld
systemctl stop NetworkManager
systemctl disable NetworkManager
echo

echo "Creating Stack User"
sleep 2
adduser stack
echo "stack:equiinfra" | chpasswd
echo "stack        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/stack
chmod 0400 /etc/sudoers.d/stack
echo

yum install yum-plugin-versionlock -y
#cd orange-stack/java-contrail-4.1.1/
#yum downgrade java-1.8.0-openjdk-1.8.0.151-5.b12.el7_4.x86_64.rpm java-1.8.0-openjdk-headless-1.8.0.151-5.b12.el7_4.x86_64.rpm -y
#yum install java-1.8.0-openjdk-1.8.0.151-5.b12.el7_4.x86_64.rpm java-1.8.0-openjdk-headless-1.8.0.151-5.b12.el7_4.x86_64.rpm -y
#yum versionlock java-1.8.0-openjdk java-1.8.0-openjdk-headless

echo

echo "Root is done...please reboot"
sleep 2

#reboot

#! /bin/bash

echo "Re-Adjusting NTP"
sleep 2
sudo echo "driftfile /var/lib/ntp/drift
restrict default nomodify notrap nopeer noquery

restrict 127.0.0.1
restrict ::1
restrict 172.17.14.0 mask 255.255.255.0 nomodify notrap
server 127.127.1.0
fudge 127.127.1.0 stratum 10

includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
disable monitor" > /etc/ntp.conf

sudo systemctl restart ntpd
sleep 2
sudo systemctl status ntpd
echo
sudo ntpstat
echo
echo "System will reboot..."
read
sudo reboot

#! /bin/bash
echo
echo "PLEASE RUN AS ROOT "
read 

cat << 'EOF' > /root/distribution-cron.sh      
#! /bin/bash
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/stack/.local/bin:/home/stack/bin

STATUS=$(systemctl status docker-distribution | grep "Active: active (running)")     
if [ -z "$STATUS" ]
then
  systemctl restart docker-distribution   
fi
EOF

sudo chmod +x /root/distribution-cron.sh   
sudo echo "* * * * * /root/distribution-cron.sh" >> /var/spool/cron/root

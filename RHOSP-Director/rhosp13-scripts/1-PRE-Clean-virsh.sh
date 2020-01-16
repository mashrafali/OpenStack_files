#! /bin/bash

for i in {0..2}
do
  for j in {controller,compute,ceph}
  do
    vbmc stop $j-$i 2> /dev/null
    vbmc delete $j-$i 2> /dev/null
  done
done

for i in {0..2}
do
  for node in {compute,ceph,controller,contrail-analytics,contrail-analytics-database,contrail-controller}
  do
    virsh destroy $node-$i                        2> /dev/null
    virsh undefine $node-$i --remove-all-storage  2> /dev/null
  done
done

vbmc list 2> /dev/null

cat <<'EOF' > /etc/rc.d/rc.local
#!/bin/bash

touch /var/lock/subsys/local

EOF

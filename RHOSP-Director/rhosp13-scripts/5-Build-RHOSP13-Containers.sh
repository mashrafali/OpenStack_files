#! /bin/bash

echo
echo "- Care for Stack PASSWD in script"
echo "- Care for director IP in push-destination"
echo
read

sudo groupadd docker
sudo usermod -aG docker stack
source /home/stack/stackrc
mkdir -p /home/stack/templates

openstack overcloud container image prepare \
  --namespace=registry.access.redhat.com/rhosp13 \
  --push-destination=172.17.14.10:8787 \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
  --set ceph_namespace=registry.access.redhat.com/rhceph \
  --set ceph_image=rhceph-3-rhel7 \
  --prefix=openstack- \
  --tag-from-label {version}-{release} \
  --output-env-file=/home/stack/templates/overcloud_images.yaml \
  --output-images-file /home/stack/local_registry_images.yaml

echo "equiinfra" | exec su -l stack

openstack overcloud container image upload \
  --config-file  /home/stack/local_registry_images.yaml \
  --verbose

sleep 10
curl http://director:8787/v2/_catalog | jq .repositories[]


# https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/13/html/director_installation_and_usage/configuring-a-container-image-source
# Section 5.5

# OFFLINE REGISRTY:
# https://access.redhat.com/articles/3348761


#!/bin/sh

set -o errexit
set -o nounset

N=$1

# ============ remove network adapter rules fil in order to regenerate it on boot
rm /etc/udev/rules.d/70-persistent-net.rules

# ============ fix the IP address to be 192.168.1.$N

ETH1_CONFIG="/etc/sysconfig/network-scripts/ifcfg-eth1"
sed -i "s/=dhcp/=static/g" $ETH1_CONFIG
sed -i "s/192\.168\.39\.52/192\.168\.39\.$N/g" $ETH1_CONFIG

# ============  set hostname to be nodeX.cloudera
NEW_HOSTNAME="node$N.cloudera"
hostname $NEW_HOSTNAME
sed -i "s/HOSTNAME=.*/HOSTNAME=$NEW_HOSTNAME/g" /etc/sysconfig/network
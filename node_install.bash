#!/bin/bash

set -o errexit
set -o nounset

N=$1

# ============ fix the IP address to be 192.168.1.$N

ETH0_CONFIG="/etc/sysconfig/network-scripts/ifcfg-eth0"
sed -i "s/=dhcp/=static/g" $ETH0_CONFIG
echo "IPADDR=192.168.39.$N" >> $ETH0_CONFIG
echo "NETMASK=255.255.255.0" >> $ETH0_CONFIG

# ============ install other things
yum -y install wget

#wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
#rpm -Uvh epel-release-latest-6.noarch.rpm
yum install epel-release
sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo

wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
rpm -i rpmforge-release-0.5.3-1.el6.rf.*.rpm

yum -y install htop
yum -y install iotop
yum -y install jnettop
yum -y install vim
yum -y install mc

# ============ NTP
yum -y install ntp ntpdate ntp-doc
chkconfig ntpd on
# ntpdate pool.ntp.org
service ntpd start

# ============  set hostname to be nodeX.cloudera
bash -c 'x=1; while [ $x -le 50 ]; do echo "192.168.39.$x node$x.cloudera"; let x=x+1; done' >>/etc/hosts
echo '192.168.39.51 quickstart.cloudera' >> /etc/hosts
NEW_HOSTNAME="node$N.cloudera"
hostname $NEW_HOSTNAME
sed -i "s/HOSTNAME=.*/HOSTNAME=$NEW_HOSTNAME/g" /etc/sysconfig/network
service network restart

# ============  switch off the iptables
service iptables stop
chkconfig iptables off
service ip6tables stop
chkconfig ip6tables off

# ============  SELinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
cat /etc/selinux/config | grep SELINUX=

# ============  performance improving
echo "echo 'never' > /sys/kernel/mm/redhat_transparent_hugepage/defrag" >> /etc/rc.local
echo 'sysctl -w vm.swappiness=0' >> /etc/rc.local
sysctl -w vm.swappiness=0
echo 'never' > /sys/kernel/mm/redhat_transparent_hugepage/defrag


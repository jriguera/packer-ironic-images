#!/bin/bash -eux

INSTALL_LIST="curl wget htop iotop tcpdump unzip vim-minimal ethtool lsscsi lshw
              lsof nano parted rsync pciutils strace logrotate man man-pages"

UNINSTALL_LIST="biosdevname NetworkManager polkit"

echo "* Installing packages ..."
for package in ${INSTALL_LIST}; do
	yum install -y ${package}
done
# Other services
yum install -y ntp
chkconfig ntpd on
yum install -y rng-tools
chkconfig rngd on
yum install -y acpid
chkconfig acpid on

echo "* Uninstalling packages ..."
for package in ${UNINSTALL_LIST}; do
	yum erase -y ${package}
done

# Installing firmware
yum install -y bfa-firmware

# Disable the release upgrader
echo "* Disabling the release upgrader"
[ -e /etc/yum/pluginconf.d/refresh-packagekit.conf ] && sed -i 's/^enabled=.*$/enabled=0/' /etc/yum/pluginconf.d/refresh-packagekit.conf || true


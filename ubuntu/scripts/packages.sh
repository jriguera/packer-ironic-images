#!/bin/bash -eux

INSTALL_LIST="curl wget htop iotop tcpdump unzip vim-nox ethtool lsscsi lshw
             lsof nano parted rsync pciutils strace logrotate iftop nload"

UNINSTALL_LIST="pppoeconf pppconfig ppp landscape-common wireless-tools wpasupplicant"

echo "* Installing packages ..."
for package in ${INSTALL_LIST}; do
	apt-get install -y ${package}
done
# Other services
apt-get install -y rng-tools
apt-get install -y acpid

echo "* Uninstalling packages ..."
for package in ${UNINSTALL_LIST}; do
	apt-get remove -y --purge ${package}
done

# Disable the release upgrader
echo "* Disabling the release upgrader"
sed -i 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades


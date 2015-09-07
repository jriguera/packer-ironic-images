#!/bin/bash -eux

echo "* Cleaning gem cache"
rm -rf /var/lib/gems/1.9.1/cache/*

echo "* Cleanup apt cache"
apt-get -y autoremove --purge
apt-get -y autoclean
apt-get -y clean

echo "* Remove the utmp file"
rm -f /var/run/utmp

echo "* Remove udev rules"
rm -rf /dev/.udev/
rm -f /etc/udev/rules.d/70-persistent-net.rules

echo "* Remove temporary files"
rm -rf /tmp/*
rm -rf /var/tmp/*

echo "* Remove ssh client directories"
rm -rf /home/*/.ssh
rm -rf /root/.ssh

echo "* Remove ssh server keys"
rm -rf /etc/ssh/*_host_*

echo "* Remove the PAM data"
rm -rf /var/run/console/*
rm -rf /var/run/faillock/*
rm -rf /var/run/sepermit/*

echo "* Remove package manager cache" 
find /var/cache/apt/archives/ -type f -exec rm -f {} \;

echo "* Remove the process accounting log files"
if [ -d /var/log/account ]; then
    rm -f /var/log/account/pacct*
    touch /var/log/account/pacct
fi

echo "* Remove email from the local mail spool directory"
rm -rf /var/spool/mail/*
rm -rf /var/mail/*

echo "* Remove the local machine ID"
if [ -d /etc/machine-id ]; then
    rm -f /etc/machine-id
    touch /etc/machine-id
fi

echo "* Clearing last login information"
>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp

echo "* Empty log files"
find /var/log -type f | while read f; do echo -ne '' > $f; done;

echo "* Cleaning up leftover dhcp leases"
# Ubuntu 10.04
if [ -d "/var/lib/dhcp3" ]; then
    rm /var/lib/dhcp3/*
fi
# Ubuntu 12.04 & 14.04
if [ -d "/var/lib/dhcp" ]; then
    rm /var/lib/dhcp/*
fi 

echo "* Remove blkid tab"
rm -f /dev/.blkid.tab
rm -f /dev/.blkid.tab.old

echo "* Remove hosts, hostname and resolv.conf"
> /etc/resolv.conf
sed -i '/^127.0.1.1/d' /etc/hosts
echo "ubuntu" > /etc/hostname

echo "* Remove Bash history"
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/*/.bash_history

echo "* Installed packages:"
dpkg -l

sleep 10

echo "* Flag the system for reconfiguration"
touch /.unconfigured

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early before the large files are deleted
sync

# CentOS 6.x kickstart file
#
# For more information on kickstart syntax and commands, refer to the
# CentOS Installation Guide:
# https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s1-kickstart2-options.html
#
# For testing, you can fire up a local http server temporarily.
# cd to the directory where this ks.cfg file resides and run the following:
#    $ python -m SimpleHTTPServer
# You don't have to restart the server every time you make changes.  Python
# will reload the file from disk every time.  As long as you save your changes
# they will be reflected in the next HTTP download.  Then to test with
# a PXE boot server, enter the following on the PXE boot prompt:
#    > linux text ks=http://<your_ip>:8000/ks.cfg

# Main settings
lang en_US.UTF-8
keyboard us
timezone Europe/Amsterdam
install
cdrom
text
skipx

# User settings
authconfig --enableshadow --enablemd5
rootpw centos
user --name=centos --plaintext --password centos

# Optional settings
unsupported_hardware
network --device eth0 --bootproto dhcp
firewall --disabled
selinux --permissive

# Disk settings
zerombr
bootloader --location=mbr --driveorder=sda --append="rhgb quiet"
clearpart --all --initlabel --drives=sda
part /boot --fstype ext4 --size=400 --ondisk=sda
part pv.01 --size=1 --grow --ondisk=sda
volgroup system pv.01
logvol / --fstype ext4 --name=root --vgname=system --size=4000
logvol /var --fstype ext4 --name=var --vgname=system --size=3000
logvol /home --fstype ext4 --name=home --vgname=system --size=1000
logvol /tmp --fstype ext4 --name=tmp --vgname=system --size=1000
logvol swap --fstype swap --name=swap --vgname=system --size=512

# Reboot after install 
reboot

%packages --nobase --excludedocs --instLangs=en
@core
kernel
chkconfig
openssh-clients
openssh-server
dhclient
iputils
sudo
dmraid
kpartx
mdadm
%end

%post
# Lock root account
passwd -l root

# Configure user in sudoers and remove root password
echo "centos ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/centos
chmod 0440 /etc/sudoers.d/centos
sed -i "s/^\(.*requiretty\)$/#\1/" /etc/sudoers

# Disable firewall
chkconfig ip6tables off
chkconfig iptables off
%end

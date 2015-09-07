
# Install the packages
sudo apt-get install qemu-utils virtinst virt-viewer libguestfs-tools
sudo apt-get install qemu-kvm qemu-system libvirt-bin bridge-utils virt-manager

# Your user should be part of the libvirtd group to manage vms
sudo adduser $USER libvirtd
sudo adduser $USER kvm
# change the current group ID during this session.
newgrp libvirtd
newgrp kvm

# Check if everything is working:
virsh -c qemu:///system list

# Main guide: http://docs.openstack.org/image-guide/content/ubuntu-image.html

# Download the ubuntu iso
wget http://archive.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/current/images/netboot/mini.iso -O /tmp/mini.iso

# Create the disk
qemu-img create -f qcow2 /tmp/trusty.qcow2 10G

virt-install --virt-type kvm --name trusty \
    --ram 1024 \
    --cdrom=/tmp/mini.iso \
    --disk /tmp/trusty.qcow2,format=qcow2 \
    --network network=default \
    --graphics vnc,listen=0.0.0.0 \
    --noautoconsole \
    --os-type=linux \
    --os-variant=ubuntutrusty

# Type virt-manager to open the console ...
virt-manager

# Installation parameters within the console:
#Hostname=ubuntu
#Domain=(empty)
#User/password=ubuntu/ubuntu
#Disk=Entire disk with LVM, separate partitions

LVM, root=4G, home=1G, var=3G, swap=1G


# There is a known bug in Ubuntu 14.04; when you select "Continue", the virtual machine will shut down, even though it says it will reboot.
# To remove the (virtual) CDRom (after the installation)
virsh start trusty --paused
virsh attach-disk --type cdrom --mode readonly trusty "" hdc
virsh resume trusty

# Login with ubuntu/ubuntu on the console:
sudo apt-get install ssh cloud-init

# To reconfigure cloud-init (user, metadata services ...)
# If the image is going to be deployed with Ironic, the "Openstack native 
# metadata service" is not needed, but if it is for Nova deployments you
# have to enable it. Ofc, if you do not want to waste time o boot (and wait
# for timeouts) you should disable all services except ConfigDrive
sudo dpkg-reconfigure cloud-init

# Shutdown the vm
sudo /sbin/shutdown -h now

# Back again to the main host. There is a utility called virt-sysprep, that 
# performs various cleanup tasks such as removing the MAC address references, 
# logs, history, ....
virt-sysprep -d trusty
virt-sysprep --enable abrt-data,bash-history,blkid-tab,crash-data,cron-spool,dhcp-client-state,dhcp-server-state,flag-reconfiguration,hostname,logfiles,machine-id,mail-spool,net-hostname,net-hwaddr,pacct-log,package-manager-cache,pam-data,random-seed,ssh-hostkeys,ssh-userdir,tmp-files,udev-persistent-net,user-account,utmp -d trusty

# Undefine the libvirt domain
virsh undefine trusty



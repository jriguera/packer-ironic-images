# packer-ironic-images

Automated way to create baremetal images with packer and qemu-kvm for Openstak Ironic deployments
Have a look https://github.com/jriguera/ansible-ironic-standalone to install Ironic server (standalone) 

# Usage (on Ubuntu)

1. Install packer from https://www.packer.io/intro/getting-started/setup.html
```sh
# Download packer (choose the latest version)
wget https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip  -O /tmp/packer.zip
sudo unzip /tmp/packer.zip -d /usr/local/bin
rm -f /tmp/packer.zip
```

2. Install qemu-kvm
```sh
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
```

3. Run a packer template
```sh
# Building an ubuntu baremetal image
cd ubuntu
packer build  ubuntu-14.04.latest-amd64.json
# output in the new folder output-ubuntu-14.04 
```

4. Optionally, copy to Ironic server and use it
```sh
# Based on https://github.com/jriguera/ansible-ironic-standalone
# the variable is baremetal_server_images_path (on the ironic role is ironic_pxe_images_path)
md5sum output-ubuntu-14.04/trusty.qcow2 > output-ubuntu-14.04/trusty.md5
# Copy the md5 and qcow
scp output-ubuntu-14.04/trusty.*  IRONIC_SERVER:/var/lib/ironic/http/images/
```

# Author

José Riguera López

#!/bin/bash -eux

DATASOURCE_LIST="ConfigDrive, Openstack, None"
# Comma list of choices: 
#    NoCloud: Reads info from /var/lib/cloud/seed only, 
#    ConfigDrive: Reads data from Openstack Config Drive, 
#    OpenNebula: read from OpenNebula context disk, 
#    Azure: read from MS Azure cdrom. Requires walinux-agent, 
#    AltCloud: config disks for RHEVm and vSphere, 
#    OVF: Reads data from OVF Transports, 
#    MAAS: Reads data from Ubuntu MAAS, 
#    GCE: google compute metadata service, 
#    OpenStack: native openstack metadata service, 
#    CloudSigma: metadata over serial for cloudsigma.com, 
#    Ec2: reads data from EC2 Metadata service, 
#    CloudStack: Read from CloudStack metadata service, 
#    None: Failsafe datasource

### Install repo
echo "* Installing EPEL repository for cloud-init"
#rpm -Uvh https://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum install -y epel-release

### Install packages
echo "* Installing cloud-init"
yum install -y cloud-init cloud-utils-growpart

### Setup main configuration
echo "* Installing cloud-init configuration"
cat <<EOF > /etc/cloud/cloud.cfg
# The top level settings are used as module
# and system configuration.

# A set of users which may be applied and/or used by various modules
# when a 'default' entry is found it will reference the 'default_user'
# from the distro configuration specified below
users:
 - default

# If this is set, 'root' will not be able to ssh in and they 
# will get a message to login instead as the above $user (ubuntu)
disable_root: true

# This will cause the set+update hostname module to not operate (if true)
preserve_hostname: false

# Enable ssh passwords
ssh_pwauth: true

# render template default-locale.tmpl to locale_configfile
locale_configfile: /etc/sysconfig/i18n

# mount_default_fields
# These values are used to fill in any entries in 'mounts' that are not
# complete.  This must be an array, and must have 7 fields.
mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']

resize_rootfs_tmp: /dev
syslog_fix_perms: ~

# If existing ssh keys should be deleted on a per-instance basis. On a public 
# image, this should absolutely be set to 'True'
ssh_deletekeys: true

# a list of the ssh key types that should be generated. These are passed to 
# 'ssh-keygen -t'
ssh_genkeytypes: ['rsa', 'dsa', 'ecdsa']

# remove access to the ec2 metadata service early in boot via null route
disable_ec2_metadata: True

# Enabled datasources
datasource_list: [ $DATASOURCE_LIST ]

cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - rsyslog
 - users-groups
 - ssh

cloud_config_modules:
 - mounts
 - locale
 - set-passwords
 - yum-add-repo
 - package-update-upgrade-install
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd

cloud_final_modules:
 - rightscale_userdata
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message

system_info:
  default_user:
    name: centos
    lock_passwd: False
    plain_text_passwd: 'centos'
    gecos: Cloud User
    groups: [wheel, adm, audio, cdrom, dialout, floppy, video, dip]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: rhel
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: sshd

EOF

### Setup LVM PV grow
echo "* Installing grow PV configuration"
cat <<EOF > /etc/cloud/cloud.cfg.d/10_growpv.cfg
# boot commands
# default: none
# this is very similar to runcmd, but commands run very early
# in the boot process, only slightly after a 'boothook' would run.
# bootcmd should really only be used for things that could not be
# done later in the boot process.  bootcmd is very much like
# boothook, but possibly with more friendly.
#  * bootcmd will run on every boot
#  * the INSTANCE_ID variable will be set to the current instance id.
#  * you can use 'cloud-init-boot-per' command to help only run once

# Centos HACK
# 1. Network does not work with cloud-init unless network service is restarted
# 2. partprobe and partx does not work reload the partition table
# So, I have decided to reboot the server (only first time after installation)

bootcmd:
 - [ cloud-init-per, once, growpart_sda2, growpart, /dev/sda, 2 ]
 - [ cloud-init-per, once, partx_sda, partx, -v, -a, /dev/sda ]
 - [ cloud-init-per, once, partprobe_sda, partprobe, /dev/sda ]
 - [ cloud-init-per, once, reboot, reboot ]
 - [ cloud-init-per, once, reboot_sleep, sleep, 1m ]
 - [ cloud-init-per, once, pvresize_system, pvresize, /dev/sda2 ]

EOF


